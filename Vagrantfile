## Deploy a local Ushahidi in the standard SBTF config
## Useful for testing
##
## To have the ssh login work you need to add vagrant
## ssh-config to your .ssh/config file

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Set memory size
  config.vm.customize do |vm|
    vm.memory_size = 1024
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-lucid-64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host only network IP, allowing you to access it
  # via the IP.
  config.vm.network "33.33.33.10"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port "http", 80, 8090

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Provisioning with Shell
  # Doesn't quite work because it's not an interactive shell
  #config.vm.provision :shell do |shell|
  #  shell.path = "scripts/production-bootstrap.sh"
  #  shell.args = "ushahidi"
  #end
end
