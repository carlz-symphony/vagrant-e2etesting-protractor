VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = 'https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/14.04/providers/virtualbox.box'
  config.vm.synced_folder "GettingStarted/", "/home/vagrant/GettingStarted" ,  type: "rsync"
  config.vm.synced_folder "TESTS/", "/home/vagrant/TESTS" ,  type: "rsync"
  config.vm.network :forwarded_port, guest:4444, host:4444
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provision "shell", path: "script.sh"

  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.memory = 1024
  end
end
