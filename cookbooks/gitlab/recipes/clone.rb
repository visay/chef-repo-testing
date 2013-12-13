#
# Cookbook Name:: gitlab
# Recipe:: clone
#

gitlab = node['gitlab']

# If cloning from a private repository we need to use a deploy key
# Based on application cookbook: https://github.com/poise/application/blob/v4.1.4/templates/default/deploy-ssh-wrapper.erb
unless gitlab['deploy_key'].empty?
  template File.join(gitlab['home'], ".ssh", "deploy-ssh-wrapper.sh") do
    source "deploy-ssh-wrapper.erb"
    user gitlab['user']
    group gitlab['group']
    mode 0755
    variables({
      :path => File.join(gitlab['home'], ".ssh")
    })
    action :create_if_missing
  end

  file File.join(gitlab['home'], ".ssh", "id_deploy_key") do
    mode 0600
    content gitlab['deploy_key']
    user gitlab['user']
    group gitlab['group']
    action :create_if_missing
  end
end

# 6. GitLab
## Clone the Source
git gitlab['path'] do
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  ssh_wrapper File.join(gitlab['home'], ".ssh", "deploy-ssh-wrapper.sh") unless gitlab['deploy_key'].empty?
  action :sync
  notifies :delete, "file[gems]", :immediately
  notifies :delete, "file[migrate]", :immediately
  notifies :delete, "file[gitlab start]", :immediately
end

## Section below won't be triggered on the first run
## This will update gitlab instance when the revision attribute changes

bundle_run = file "gems" do
  path File.join(gitlab['home'], ".gitlab_gems_#{gitlab['env']}")
  notifies :run, "execute[bundle on update]", :immediately
  action :nothing
end

# Since correct bundle install ran at the first run
# this will install the gems after we checkout new branch
# Needed before we stop GitLab instance because sidekiq won't get shut down properly otherwise
execute "bundle on update" do
  command "bundle"
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  only_if { bundle_run.updated_by_last_action? }
end

file "migrate" do
  path File.join(gitlab['home'], ".gitlab_migrate_#{gitlab['env']}")
  action :nothing
end

gitlab_run = file "gitlab start" do
  path File.join(gitlab['home'], ".gitlab_start")
  action :nothing
  notifies :stop, "service[gitlab]", :immediately
end

service "gitlab" do
  action :nothing
  only_if { gitlab_run.updated_by_last_action? }
end
