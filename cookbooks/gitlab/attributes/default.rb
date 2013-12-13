# Package
if platform_family?("rhel")
  packages = %w{
    libicu-devel libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel
    libyaml-devel readline-devel curl-devel openssl-devel pcre-devel git memcached-devel valgrind-devel mysql-devel gcc-c++
    ImageMagick-devel ImageMagick
  }
else
  packages = %w{
    build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev
    curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python-docutils
    logrotate vim curl wget checkinstall
  }
end

default['gitlab']['packages'] = packages
default['gitlab']['ruby'] = "2.0.0-p353"

# GitLab shell
default['gitlab']['shell_repository'] = "https://github.com/gitlabhq/gitlab-shell.git"
default['gitlab']['shell_revision'] = "v1.7.9"

# GitLab hq
default['gitlab']['repository'] = "https://github.com/gitlabhq/gitlabhq.git"
default['gitlab']['deploy_key'] = "" # Optional. Private key used to connect to private GitLab repository.

# GitLab shell config
default['gitlab']['redis_path'] = "/usr/local/bin/redis-cli"
default['gitlab']['redis_host'] = "127.0.0.1"
default['gitlab']['redis_port'] = "6379"
default['gitlab']['namespace']  = "resque:gitlab"

# GitLab hq config
default['gitlab']['git_path'] = "/usr/local/bin/git"
default['gitlab']['host'] = "localhost"

default['gitlab']['email_from'] = "gitlab@localhost"
default['gitlab']['support_email'] = "support@localhost"

# Gems
default['gitlab']['bundle_install'] = "SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment"

# Assumed defaults
# database: mysql (option: postgresql)
# environment: production (option: development)

default['gitlab']['database_adapter'] = "mysql"
default['gitlab']['database_password'] = "datapass"
default['gitlab']['database_user'] = "git"
default['gitlab']['env'] = "production"

default['mysql']['server_host'] = "localhost"
default['mysql']['server_root_password'] = "rootpass"
default['mysql']['server_repl_password'] = "replpass"
default['mysql']['server_debian_password'] = "debianpass"

default['postgresql']['password']['postgres'] = "psqlpass"
default['postgresql']['server_host'] = "localhost"

default['postfix']['mail_type'] = "client"
default['postfix']['myhostname'] = "mail.localhost"
default['postfix']['mydomain'] = "localhost"
default['postfix']['myorigin'] = "mail.localhost"
default['postfix']['smtp_use_tls'] = "no"

# User
default['gitlab']['user'] = "git" # Do not change this attribute in production since some code from the GitLab repo such as init.d script assume it is git.
default['gitlab']['group'] = "git"
default['gitlab']['home'] = "/home/git"

# GitLab shell
default['gitlab']['shell_path'] = "/home/git/gitlab-shell"

# GitLab hq
default['gitlab']['path'] = "/home/git/gitlab" # Do not change this attribute in production since some code from the GitLab repo such as init.d assume this path.

# GitLab shell config
default['gitlab']['repos_path'] = "/home/git/repositories"

# GitLab hq config
default['gitlab']['satellites_path'] = "/home/git/gitlab-satellites"

# Unicorn specific configuration
default['gitlab']['unicorn_workers_number'] = 2
default['gitlab']['unicorn_timeout'] = 30

# Setup environments
if node['gitlab']['env'] == "development"
  default['gitlab']['port'] = "3000"
  default['gitlab']['url'] = "http://localhost:3000/"
  default['gitlab']['revision'] = "master"
  default['gitlab']['environments'] = %w{development test}
else
  default['gitlab']['environments'] = %w{production}
  default['gitlab']['url'] = "http://localhost:80/"
  default['gitlab']['revision'] = "6-3-stable" # Must be branch, otherwise GitLab update will run on each chef run
  default['gitlab']['port'] = "80"
end

# Nginx ssl certificates

default['gitlab']['ssl_certificate_path'] = "/etc/ssl" # Path to .crt file. If it directory doesn't exist it will be created
default['gitlab']['ssl_certificate_key_path'] = "/etc/ssl" # Path to .key file. If directory doesn't exist it will be created
default['gitlab']['ssl_certificate'] = "" # SSL certificate
default['gitlab']['ssl_certificate_key'] = "" # SSL certificate key

# AWS is disabled by default. If enabled is set to true, bundler will install gems from aws group and use the credentials to populate config/aws.yml
default['gitlab']['aws'] = {
  :enabled => false,
  :provider => 'AWS', # required
  :aws_access_key_id     => 'yyy', # required
  :aws_secret_access_key => 'xxx', # required
  :bucket => 'zzz', # optional
  :region => 'eu-west-1', # optional, defaults to 'us-east-1'
  :host     => 's3.example.com', # optional, defaults to nil
  :endpoint  => 'https://s3.example.com:8080' # optional, defaults to nil
}

# Monit specific configuration
default['gitlab']['monitrc']['sidekiq'] = {
  :pid_path => "#{default['gitlab']['path']}/tmp/pids/sidekiq.pid",
  :start_timeout => "80", # in seconds
  :stop_timeout => "40", # in seconds
  :cpu_threshold => "40", # in %. Assuming our server has two cores, 40% totalcpu means pinning 80% of a single core
  :cpu_cycles_number => "10",
  :mem_threshold => "225", # in MB
  :mem_cycles_number => "10",
  :restart_number => "5", # Number of consecutive restarts before alerting.
  :restart_cycles_number => "5" # Number of cycles to monitor for consecutive restarts.
}

default['gitlab']['monitrc']['unicorn'] = {
  :pid_path => "#{default['gitlab']['path']}/tmp/pids/unicorn.pid",
  :mem_threshold => "1000.0", # in MB
  :mem_cycles_number => "25"
}
default['gitlab']['monitrc']['notify_email'] = "monitrc@localhost"
