#
# Cookbook Name:: gitlab
# Recipe:: monit
#
gitlab = node['gitlab']
monitrc = gitlab['monitrc']

include_recipe "monit::default"

sidekiq = monitrc['sidekiq']
monit_monitrc "sidekiq" do
  variables ({
    gitlab_user: gitlab['user'],
    gitlab_path: gitlab['path'],
    sidekiq_pid_path: sidekiq['pid_path'],
    start_timeout: sidekiq['start_timeout'],
    stop_timeout: sidekiq['stop_timeout'],
    cpu_threshold: sidekiq['cpu_threshold'],
    cpu_cycles_number: sidekiq['cpu_cycles_number'],
    mem_threshold: sidekiq['mem_threshold'],
    mem_cycles_number: sidekiq['mem_cycles_number'],
    restart_number: sidekiq['restart_number'],
    restart_cycles_number: sidekiq['restart_cycles_number'],
    notify_email: monitrc['notify_email']
  })
end

unicorn = monitrc['unicorn']
monit_monitrc "unicorn" do
  variables ({
    gitlab_user: gitlab['user'],
    gitlab_path: gitlab['path'],
    unicorn_pid_path: unicorn['pid_path'],
    mem_threshold: unicorn['mem_threshold'],
    mem_cycles_number: unicorn['mem_cycles_number'],
    notify_email: monitrc['notify_email']
  })
end

directory "#{gitlab['path']}/bin" do
  user gitlab['user']
  group gitlab['group']
  mode 0755
  action :create
end

file "#{gitlab['path']}/bin/test_sidekiq_max_workers.sh" do
  mode 0755
  action :create_if_missing
end
