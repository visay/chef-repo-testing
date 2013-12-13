name             'gitlab'
maintainer       'Marin Jankovski'
maintainer_email 'marin@gitlab.com'
license          'MIT'
description      'Installs/Configures GitLab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.3'

recipe "gitlab::default", "Installation"

%w{ redisio ruby_build postgresql mysql database postfix yum phantomjs magic_shell apt monit }.each do |dep|
  depends dep
end

%w{ debian ubuntu centos }.each do |os|
  supports os
end
