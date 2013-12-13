#
# Cookbook Name:: gitlab
# Recipe:: install
#

gitlab = node['gitlab']

### Copy the example GitLab config
template File.join(gitlab['path'], 'config', 'gitlab.yml') do
  source "gitlab.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :host => gitlab['host'],
    :port => gitlab['port'],
    :user => gitlab['user'],
    :email_from => gitlab['email_from'],
    :support_email => gitlab['support_email'],
    :satellites_path => gitlab['satellites_path'],
    :repos_path => gitlab['repos_path'],
    :shell_path => gitlab['shell_path']
  })
  notifies :run, "bash[git config]", :immediately
end

### Make sure GitLab can write to the log/ and tmp/ directories
### Create directories for sockets/pids
### Create public/uploads directory otherwise backup will fail
%w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

### Create directory for satellites
directory gitlab['satellites_path'] do
  owner gitlab['user']
  group gitlab['group']
end

### Unicorn config
template File.join(gitlab['path'], 'config', 'unicorn.rb') do
  source "unicorn.rb.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :unicorn_workers_number => gitlab['unicorn_workers_number'],
    :unicorn_timeout => gitlab['unicorn_timeout']
  })
end

### Enable Rack attack
# Creating the file this way for the following reasons
# 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
# 2. Using file resource is not an option because it is ran at compilation time
# and at that point the file doesn't exist
# 3. Using cookbook_file resource is not an option because we do not want to include the file
# in the cookbook for maintenance reasons. Same for template resource.
# 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
# see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
# 5 Using bash and execute resource is not an option because they would run at every chef run
# and supplying a restriction in the form of "not_if" would prevent an update of a file
# if there is any
# Ruby block is compiled at compilation time but only executed during execution time
# allowing us to create a resource.

ruby_block "Copy from example rack attack config" do
  block do
    resource = Chef::Resource::File.new("rack_attack.rb", run_context)
    resource.path File.join(gitlab['path'], 'config', 'initializers', 'rack_attack.rb')
    resource.content IO.read(File.join(gitlab['path'], 'config', 'initializers', 'rack_attack.rb.example'))
    resource.owner gitlab['user']
    resource.group gitlab['group']
    resource.mode 0644
    resource.run_action :create
  end
end

### Configure Git global settings for git user, useful when editing via web
bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab"
    git config --global user.email "gitlab@#{gitlab['host']}"
    git config --global core.autocrlf input
  EOS
  user gitlab['user']
  group gitlab['group']
  environment('HOME' => gitlab['home'])
  action :nothing
end

## Configure GitLab DB settings
template File.join(gitlab['path'], "config", "database.yml") do
  source "database.yml.#{gitlab['database_adapter']}.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['database_user'],
    :password => gitlab['database_password']
  })
end

### db:setup
file_setup = File.join(gitlab['home'], ".gitlab_setup_#{gitlab['env']}")
file_setup_old = File.join(gitlab['home'], ".gitlab_setup")
execute "rake db:setup" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:setup RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(file_setup) || File.exists?(file_setup_old)}
end

file file_setup do
  owner gitlab['user']
  group gitlab['group']
  action :create
end

### db:migrate
file_migrate = File.join(gitlab['home'], ".gitlab_migrate_#{gitlab['env']}")
file_migrate_old = File.join(gitlab['home'], ".gitlab_migrate")
execute "rake db:migrate" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:migrate RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(file_migrate) || File.exists?(file_migrate_old)}
end

### db:seed_fu
file_seed = File.join(gitlab['home'], ".gitlab_seed_#{gitlab['env']}")
file_seed_old = File.join(gitlab['home'], ".gitlab_seed")
execute "rake db:seed_fu" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:seed_fu RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(file_seed) || File.exists?(file_seed_old)}
end

file file_seed do
  owner gitlab['user']
  group gitlab['group']
  action :create
end

case gitlab['env']
when 'production'
  ## Setup Init Script
  # Creating the file this way for the following reasons
  # 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
  # 2. Using file resource is not an option because it is ran at compilation time
  # and at that point the file doesn't exist
  # 3. Using cookbook_file resource is not an option because we do not want to include the file
  # in the cookbook for maintenance reasons. Same for template resource.
  # 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
  # see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
  # 5 Using bash and execute resource is not an option because they would run at every chef run
  # and supplying a restriction in the form of "not_if" would prevent an update of a file
  # if there is any
  # Ruby block is compiled at compilation time but only executed during execution time
  # allowing us to create a resource.

  ruby_block "Copy from example gitlab init config" do
    block do
      resource = Chef::Resource::File.new("gitlab_init", run_context)
      resource.path "/etc/init.d/gitlab"
      resource.content IO.read(File.join(gitlab['path'], "lib", "support", "init.d", "gitlab"))
      resource.mode 0755
      resource.run_action :create
      if resource.updated?
        self.notifies :run, resources(:execute => "set gitlab to start on boot"), :immediately
      end
    end
  end

  # Updates defaults so gitlab can boot on start. As per man pages of update-rc.d runs only if links do not exist
  execute "set gitlab to start on boot" do
    if platform_family?("debian")
      command "update-rc.d gitlab defaults 21"
    else
      command "chkconfig --level 21 gitlab on"
    end
    action :nothing
  end

  ## Setup logrotate
  # Creating the file this way for the following reasons
  # 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
  # 2. Using file resource is not an option because it is ran at compilation time
  # and at that point the file doesn't exist
  # 3. Using cookbook_file resource is not an option because we do not want to include the file
  # in the cookbook for maintenance reasons. Same for template resource.
  # 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
  # see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
  # 5 Using bash and execute resource is not an option because they would run at every chef run
  # and supplying a restriction in the form of "not_if" would prevent an update of a file
  # if there is any
  # Ruby block is compiled at compilation time but only executed during execution time
  # allowing us to create a resource.

  ruby_block "Copy from example logrotate config" do
    block do
      resource = Chef::Resource::File.new("logrotate", run_context)
      resource.path "/etc/logrotate.d/gitlab"
      resource.content IO.read(File.join(gitlab['path'], "lib", "support", "logrotate", "gitlab"))
      resource.mode 0644
      resource.run_action :create
    end
  end

  if gitlab['aws']['enabled']
    template "aws.yml" do
      owner gitlab['user']
      group gitlab['group']
      path "#{gitlab['path']}/config/aws.yml"
      mode 0755
      action :create_if_missing
      variables({
        :aws_access_key_id => gitlab['aws']['aws_access_key_id'],
        :aws_secret_access_key => gitlab['aws']['aws_secret_access_key'],
        :bucket => gitlab['aws']['bucket'],
        :region => gitlab['aws']['region'],
        :host => gitlab['aws']['host'],
        :endpoint => gitlab['aws']['endpoint']
      })
    end
  end

  execute "rake assets:clean" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake assets:clean RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if { File.exists?(file_migrate) }
  end

  execute "rake assets:precompile" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake assets:precompile RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if { File.exists?(file_migrate) }
  end

  execute "rake cache:clear" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake cache:clear RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if { File.exists?(file_migrate) }
  end
else
  ## For execute javascript test
  include_recipe "phantomjs"
end

file file_migrate do
  owner gitlab['user']
  group gitlab['group']
  action :create
end
