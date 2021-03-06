search(:ssl, '*:*') do |s|
  # replace the secret key before uploading cookbook
  ssl = Chef::EncryptedDataBagItem.load("ssl", s['id'], "###CHANGEME-SECRET-KEY###")

  cert_domain = ssl['id'].gsub('_', '.')
  install_cert(cert_domain, ssl['cert'])

  chain_certs = ssl['chain']
  if chain_certs
    combined_chain_certs = chain_certs.join("\n")
    install_cert(cert_domain, combined_chain_certs, :is_chain)
  end

  key = ssl['key']
  key_file = "#{cert_domain}.key"
  file "#{File.join node['ssl']['keys_dir'], key_file}" do
    owner 'root'
    group "#{node['ssl']['group']}"
    mode '0640'
    content key
  end

  # this is needed by nginx
  if chain_certs
    combined_certs_file = "#{cert_domain}.combined.crt"
    template "#{File.join node['ssl']['certs_dir'], combined_certs_file}" do
      source "combined_certs.erb"
      owner 'root'
      group 'root'
      mode '0644'
      variables :chain_certs => chain_certs,
                :domain_cert => ssl['cert']
    end
  end
end

# Install certificate authority
directory "#{node[:ssl][:certs_dir]}" do
  recursive true
  owner 'root'
  group "#{node['ssl']['group']}"
end

template "#{node[:ssl][:certs_dir]}/web-essentials.asia.ca" do
  source "web-essentials.asia.ca"
  owner 'root'
  group "#{node['ssl']['group']}"
  not_if { File.exists?("#{node[:ssl][:certs_dir]}/web-essentials.asia.ca") }
end