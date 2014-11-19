# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu-14.04-provisionerless'
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
  end

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = './cookbook/Berksfile'
  config.omnibus.chef_version = :latest

  config.vm.define 'mesos-build', autostart: false do |mesos|
    mesos.vm.provider :virtualbox do |vb|
      vb.memory = 10240
      vb.cpus = 4
    end

    mesos.vm.provision :shell, inline: <<EOF
#!/bin/bash +ex
chown vagrant /opt

if [ -f /etc/init.d/chef-client ]; then
  service chef-client stop
  rm /etc/init.d/chef-client
fi
EOF

    mesos.vm.provision :file,
                       source: 'mesos-0.20.0',
                       destination: '/opt/mesos'

    mesos.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::build]']
    end
  end

  config.vm.define 'zookeeper', autostart: false do |zk|
    zk.vm.provision :shell, inline: 'chown vagrant /opt'
    zk.vm.provision :file,
                    source: 'zookeeper-3.4.6',
                    destination: '/opt/zookeeper'

    zk.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::zookeeper]']
    end
  end

  config.vm.define 'mesos-master', autostart: false do |mesos|
    mesos.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::master]']
    end
  end

  config.vm.define 'mesos-slave', autostart: false do |mesos|
    mesos.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::slave]']
    end
  end
end
