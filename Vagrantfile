# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

zookeeper_nodes = %w(192.168.33.16 192.168.33.17 192.168.33.18)
master_nodes = %w(192.168.33.24 192.168.33.25 192.168.33.26)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu-14.04.1-provisionerless'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/'\
    '20141119.2/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.box_download_checksum = 'c9bd98f5073a3429e0d124127f11fa18e'\
    '3954ca5e8675adf65109f36f54508f1'
  config.vm.box_download_checksum_type = 'sha256'

  # config.vm.provider :virtualbox do |vb|
  #   vb.memory = 1024
  # end

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = './cookbook/Berksfile'
  config.omnibus.chef_version = :latest

  ##
  # Mesos build environment
  ##
  config.vm.define 'mesos-build', autostart: false do |mesos|
    mesos.vm.provider :virtualbox do |vb|
      vb.memory = 10_240
      vb.cpus = 4
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

    ## Push Mesos source to the build VM
    mesos.vm.provision :file,
                       source: 'mesos-0.20.0',
                       destination: '/opt/mesos'

    ## Do the build
    mesos.vm.provision :chef_solo do |chef|
      chef.run_list = ['recipe[mesos::build]']
    end
  end

  ##
  # Zookeeper Ensamble
  ##
  zookeeper_nodes.each_with_index do |address, id|
    config.vm.define "zookeeper-#{ id }" do |zk|
      zk.vm.hostname = "zookeeper-#{ id }"
      zk.vm.network :private_network, :ip => address

      zk.vm.provision :shell, inline: <<EOF
#!/bin/bash +ex
chown vagrant /opt

if [ -f /etc/init.d/chef-client ]; then
  service chef-client stop
  rm /etc/init.d/chef-client
fi
EOF

      zk.vm.provision :file,
                      source: 'zookeeper-3.4.6',
                      destination: '/opt/zookeeper'

      zk.vm.provision :chef_solo do |chef|
        chef.node_name = "zookeeper-#{ id }"
        chef.run_list = ['recipe[mesos::zookeeper]']
        chef.json = {
          :zookeeper => {
            :nodes => zookeeper_nodes,
            :id => id
          }
        }
      end
    end
  end

  ##
  # Mesos nodes
  ##
  master_nodes.each_with_index do |address, id|
    config.vm.define "master-#{ id }" do |mesos|
      mesos.vm.box = 'mesos-0.20.0-ubuntu-14.04.1'
      mesos.vm.hostname = "master-#{ id }"
      mesos.vm.network :private_network, :ip => address
      mesos.vm.network :forwarded_port, :guest => 5050, :host => 5050 unless id > 0

      mesos.vm.provision :chef_solo do |chef|
        chef.node_name = "master-#{ id }"
        chef.run_list = ['recipe[mesos::master]']
        chef.json = {
          :zookeeper => {
            :nodes => zookeeper_nodes
          },
          :mesos => {
            :quorum => (master_nodes.length / 2).floor + 1
          }
        }
      end
    end
  end

  # config.vm.define 'mesos-slave', autostart: false do |mesos|
  #   mesos.vm.box = 'mesos-0.20.0-ubuntu-14.04.1'
  #   mesos.vm.network :private_network, :type => 'dhcp'
  #
  #   mesos.vm.provision :chef_solo do |chef|
  #     chef.run_list = ['recipe[mesos::slave]']
  #     chef.json = {
  #       :zookeeper => {
  #         :nodes => zookeeper_nodes
  #       }
  #     }
  #   end
  # end
end
