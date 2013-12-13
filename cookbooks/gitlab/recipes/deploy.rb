#
# Cookbook Name:: gitlab
# Recipe:: deploy
#
# This recipe is used for AWS OpsWorks deploy section
# Any change must be tested against AWS OpsWorks stack

gitlab = node['gitlab']

# Fetch GitLab shell source code
include_recipe "gitlab::gitlab_shell_clone"

# Configure and install GitLab shell
include_recipe "gitlab::gitlab_shell_install"

# Fetch GitLab source code
include_recipe "gitlab::clone"

# Install required gems
include_recipe "gitlab::gems"

# Configure and install GitLab
include_recipe "gitlab::install"

if gitlab['env'] == 'production'
  # Start GitLab if in production
  include_recipe "gitlab::start"

  # Setup and configure nginx
  include_recipe "gitlab::nginx"
end
