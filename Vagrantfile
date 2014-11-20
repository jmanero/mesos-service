# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

master_nodes = %w(192.168.33.16 192.168.33.17 192.168.33.18)
slave_nodes = %w(192.168.33.24 192.168.33.25 192.168.33.26 192.168.33.27)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu-14.04.1-provisionerless'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/'\
    '20141119.2/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.box_download_checksum = 'c9bd98f5073a3429e0d124127f11fa18e'\
    '3954ca5e8675adf65109f36f54508f1'
  config.vm.box_download_checksum_type = 'sha256'

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = './cookbook/Berksfile'
  config.omnibus.chef_version = :latest

  ##
  # Mesos build environment
  ##
  config.vm.define 'mesos-build', autostart: false do |build|
    build.vm.provider :virtualbox do |vb|
      vb.memory = 10_240
      vb.cpus = 4
    end

    ## Stop and disable chef-client if the box shipped with it
    ##  configured as a service
    build.vm.provision :shell, inline: <<EOF
#!/bin/bash +ex
chown vagrant /opt

if [ -f /etc/init.d/chef-client ]; then
  service chef-client stop
  rm /etc/init.d/chef-client
fi
EOF

    ## Push Mesos source to the build VM
    build.vm.provision :file,
                       source: 'mesos-0.20.0',
                       destination: '/opt/mesos'

    ## Do the build
    build.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::build]']
    end
  end

  ##
  # Mesos Master/Zookeeper nodes
  ##
  master_nodes.each_with_index do |address, id|
    config.vm.define "master-#{ id }" do |mesos|
      mesos.vm.box = 'mesos-0.20.0-ubuntu-14.04.1'
      mesos.vm.hostname = "master-#{ id }"
      mesos.vm.network :private_network, :ip => address
      mesos.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end

      mesos.vm.provision :file,
                         source: 'zookeeper-3.4.6',
                         destination: '/opt/zookeeper'

      mesos.vm.provision :chef_solo do |chef|
        chef.log_level = :debug
        chef.node_name = "master-#{ id }"
        chef.run_list = ['recipe[mesos::zookeeper]', 'recipe[mesos::master]']
        chef.json = {
          :zookeeper => {
            :nodes => master_nodes,
            :id => id
          },
          :mesos => {
            :address => address,
            :quorum => (master_nodes.length / 2).floor + 1
          }
        }
      end
    end
  end

  ##
  # Mesos Slaves
  slave_nodes.each_with_index do |address, id|
    config.vm.define "slave-#{ id }" do |mesos|
      mesos.vm.box = 'mesos-0.20.0-ubuntu-14.04.1'
      mesos.vm.hostname = "slave-#{ id }"
      mesos.vm.network :private_network, :ip => address
      mesos.vm.provider :virtualbox do |vb|
        vb.memory = 1024
        vb.cpus = 2
      end

      ## Stop and disable chef-client if the box shipped with it
      ##  configured as a service
      mesos.vm.provision :shell, inline: <<EOF
#!/bin/bash +ex
chown vagrant /opt

if [ -f /etc/init.d/chef-client ]; then
  service chef-client stop
  rm /etc/init.d/chef-client
fi
EOF

      mesos.vm.provision :chef_solo do |chef|
        chef.log_level = :debug
        chef.node_name = "slave-#{ id }"
        chef.run_list = ['recipe[mesos::slave]']
        chef.json = {
          :zookeeper => {
            :nodes => master_nodes
          },
          :mesos => {
            :address => address
          }
        }
      end
    end
  end
end
