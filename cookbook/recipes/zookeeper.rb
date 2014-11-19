#
# Cookbook Name:: mesos
# Recipe:: zookeeper
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'apt::default'
package 'openjdk-7-jdk'

directory node['zookeeper']['config']['dataDir']
directory node['zookeeper']['logs']

## Wrap Zookeeper control script with an init script
template '/etc/init.d/zookeeper' do
  source 'zookeeper.init.erb'
  mode '0755'
end

template '/opt/zookeeper/conf/zoo.cfg' do
  source 'zookeeper.cfg.erb'
  owner 'vagrant'
  notifies :restart, 'service[zookeeper]'
end

template '/opt/zookeeper/conf/zookeeper-env.sh' do
  source 'zookeeper-env.sh.erb'
  owner 'vagrant'
  notifies :restart, 'service[zookeeper]'
end

file ::File.join(node['zookeeper']['config']['dataDir'], 'myid') do
  content "#{ node['zookeeper']['id'] }"
  owner 'vagrant'
  notifies :restart, 'service[zookeeper]'
end

service 'zookeeper' do
  action [:start, :enable]
end
