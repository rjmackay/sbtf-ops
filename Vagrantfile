## Deploy a local Ushahidi in the standard SBTF config
## Useful for testing
##
## To have the ssh login work you need to add vagrant
## ssh-config to your .ssh/config file

Vagrant::Config.run do |config|
  config.vm.customize ["modifyvm", :id, "--memory", "1024"]
  config.vm.box = "ubuntu-lucid-64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
  config.vm.network :hostonly, "33.33.33.10"
  config.vm.forward_port 80, 8090
end
