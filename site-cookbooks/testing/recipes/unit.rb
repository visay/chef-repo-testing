#
# Cookbook Name:: testing
# Recipe:: default
#
# Copyright 2013, Visay Keo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe "phpunit"

execute 'autodiscover' do
  command 'pear config-set auto_discover 1'
  action :run
end

# REGISTER NEW PEAR CHANNELS
['pear.phpqatools.org', 'pear.netpirates.net', 'pear.typo3.org'].each do |channel|
  php_pear_channel channel do
    action :discover
  end
end

# Install PHP QA Tools
php_pear "phpqatools" do
  action :install
  preferred_state "stable"
  options "--alldeps"
  channel "pear.phpqatools.org"
end

# Install php5-xls required by phpDox
case node["platform_family"]
when "rhel", "fedora"
  package "php-xsl" do
    action :install
  end
else
  package "php5-xsl" do
    action :install
  end
end

php_pear "phpDox" do
  action :install
  preferred_state "alpha"
  options "--alldeps"
  channel "pear.netpirates.net"
end

# Install TYPO3CMS Coding Standard
php_pear "TYPO3CMS" do
  action :install
  preferred_state "alpha"
  options "--alldeps"
  channel "pear.typo3.org"
end

# Install TYPO3Flow Coding Standard
php_pear "TYPO3Flow" do
  action :install
  preferred_state "beta"
  options "--alldeps"
  channel "pear.typo3.org"
end

# Install Jenkins plugins
include_recipe 'jenkins'
#plugins_to_install = node[:jenkins][:server][:plugins]

# Ensure jenkins user home dir exists
directory "#{node[:jenkins][:server][:home]}" do
  owner "#{node[:jenkins][:server][:user]}"
  group "#{node[:jenkins][:server][:user]}"
  action :create
end

# Fixes possible error:
#   STDOUT: `git` is neither a valid file, URL, nor a plugin artifact name in the update center
#   No update center data is retrieved yet from: http://updates.jenkins-ci.org/update-center.json
directory "#{node[:jenkins][:server][:home]}/updates" do
  owner "#{node[:jenkins][:server][:user]}"
  group "#{node[:jenkins][:server][:user]}"
  action :create
end
execute "update jenkins update center" do
  command "wget http://updates.jenkins-ci.org/update-center.json -qO- | sed '1d;$d'  > #{node[:jenkins][:server][:home]}/updates/default.json"
  user "#{node[:jenkins][:server][:user]}"
  group "#{node[:jenkins][:server][:user]}"
  creates "#{node[:jenkins][:server][:home]}/updates/default.json"
end

# Install all plugins and restart once
#jenkins_cli "install-plugin #{plugins_to_install.join(' ')}"

# INSTALL PHP TEMPLATE
directory "#{node[:jenkins][:server][:home]}/jobs/template-php" do
  recursive true
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

template "#{node[:jenkins][:server][:home]}/jobs/template-php/config.xml" do
  source "jobs/php/config.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/jobs/template-php/config.xml") }
end

# INSTALL CUCUMBER TEMPLATE
directory "#{node[:jenkins][:server][:home]}/jobs/template-cucumber" do
  recursive true
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

template "#{node[:jenkins][:server][:home]}/jobs/template-cucumber/config.xml" do
  source "jobs/cucumber/config.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/jobs/template-cucumber/config.xml") }
end

# INSTALL PHP CUCUMBER TEMPLATE
directory "#{node[:jenkins][:server][:home]}/jobs/template-php-cucumber" do
  recursive true
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

template "#{node[:jenkins][:server][:home]}/jobs/template-php-cucumber/config.xml" do
  source "jobs/php-cucumber/config.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/jobs/template-php-cucumber/config.xml") }
end

# INSTALL Jenkin's Configuration
directory "#{node[:jenkins][:server][:home]}" do
  recursive true
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

template "#{node[:jenkins][:server][:home]}/config.xml" do
  source "configuration/config.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/config.xml") }
end

template "#{node[:jenkins][:server][:home]}/hudson.plugins.emailext.ExtendedEmailPublisher.xml" do
  source "configuration/hudson.plugins.emailext.ExtendedEmailPublisher.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/hudson.plugins.emailext.ExtendedEmailPublisher.xml") }
end

template "#{node[:jenkins][:server][:home]}/hudson.tasks.Mailer.xml" do
  source "configuration/hudson.tasks.Mailer.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/hudson.tasks.Mailer.xml") }
end

template "#{node[:jenkins][:server][:home]}/jenkins.model.JenkinsLocationConfiguration.xml" do
  source "configuration/jenkins.model.JenkinsLocationConfiguration.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/jenkins.model.JenkinsLocationConfiguration.xml") }
end

template "#{node[:jenkins][:server][:home]}/hudson.scm.SubversionSCM.xml" do
  source "configuration/hudson.scm.SubversionSCM.xml"
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?("#{node[:jenkins][:server][:home]}/hudson.scm.SubversionSCM.xml") }
end

#jenkins_cli "safe-restart"

# Install ruby using RVM as jenkins user
rvm_ruby "#{node[:rvm][:user_default_ruby]}" do
  action  :install
  user    "#{node[:jenkins][:server][:user]}"
end

# Set a default ruby version as jenkins user
rvm_default_ruby "#{node[:rvm][:user_default_ruby]}" do
  action  :create
  user    "#{node[:jenkins][:server][:user]}"
end

# Install ruby using RVM as root user
rvm_ruby "#{node[:rvm][:user_default_ruby]}" do
  action  :install
  user    "root"
end

# Set a default ruby version as root user
rvm_default_ruby "#{node[:rvm][:user_default_ruby]}" do
  action  :create
  user    "root"
end