#
# Cookbook Name:: gitlab
# Recipe:: gitlab_shell_clone
#

gitlab = node['gitlab']

# 4. GitLab shell
## Clone gitlab shell
git gitlab['shell_path'] do
  repository gitlab['shell_repository']
  revision gitlab['shell_revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end
