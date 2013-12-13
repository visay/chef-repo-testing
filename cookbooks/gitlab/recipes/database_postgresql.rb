#
# Cookbook Name:: gitlab
# Recipe:: database_postgresql
#

postgresql = node['postgresql']
gitlab = node['gitlab']

# 5.Database
include_recipe "postgresql::server"
include_recipe "database::postgresql"

postgresql_connection = {
  :host => postgresql['server_host'],
  :username => 'postgres',
  :password => postgresql['password']['postgres']
}

## Create a user for GitLab.
postgresql_database_user gitlab['database_user'] do
  connection postgresql_connection
  password gitlab['database_password']
  action :create
end

## Create the GitLab database & grant all privileges on database
gitlab['environments'].each do |environment|
  postgresql_database "gitlabhq_#{environment}" do
    connection postgresql_connection
    action :create
  end

  postgresql_database_user gitlab['database_user'] do
    connection postgresql_connection
    database_name "gitlabhq_#{environment}"
    password gitlab['database_password']
    action :grant
  end
end
