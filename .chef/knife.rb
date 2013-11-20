current_dir = File.dirname(__FILE__)

log_level                :info
log_location             STDOUT
client_key               "#{current_dir}/client.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/chef-validator.pem"
chef_server_url          'https://chef.web-essentials.asia'

cookbook_path [
  "#{current_dir}/../cookbooks",
  "#{current_dir}/../site-cookbooks"
]

cookbook_copyright "Web Essentials"
cookbook_email     "cookbooks@web-essentials.asia"
cookbook_license   "mit"

eval(File.read(File.expand_path("#{current_dir}/knife.local.rb")))