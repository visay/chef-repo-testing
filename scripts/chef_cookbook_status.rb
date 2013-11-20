#
# % knife exec scripts/chef_cookbook_status.rb
# @source
# @author	Christian Trabold <christian.trabold@dkd.de>
# @since 2012-05-18

list = `knife cookbook list`
list.split("\n").each do |n|
  puts n + ":"
  puts %x{knife cookbook show #{n} | grep 'frozen'}
end
exit 0
