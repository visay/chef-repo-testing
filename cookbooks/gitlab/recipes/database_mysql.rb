#
# Cookbook Name:: gitlab
# Recipe:: database_mysql
#

mysql = node['mysql']
gitlab = node['gitlab']

# 5.Database
include_recipe "mysql::server"
include_recipe "database::mysql"

mysql_connection = {
  :host => mysql['server_host'],
  :username => 'root',
  :password => mysql['server_root_password']
}

## Create a user for GitLab.
mysql_database_user gitlab['database_user'] do
  connection mysql_connection
  password gitlab['database_password']
  action :create
end

## Create the GitLab database & grant all privileges on database
gitlab['environments'].each do |environment|
  mysql_database "gitlabhq_#{environment}" do
    encoding "utf8"
    collation "utf8_unicode_ci"
    connection mysql_connection
    action :create
  end

  mysql_database_user gitlab['database_user'] do
    connection mysql_connection
    password gitlab['database_password']
    database_name "gitlabhq_#{environment}"
    host 'localhost'
    privileges ["SELECT", "UPDATE", "INSERT", "DELETE", "CREATE", "DROP", "INDEX", "ALTER", "LOCK TABLES"]
    action :grant
  end
end
