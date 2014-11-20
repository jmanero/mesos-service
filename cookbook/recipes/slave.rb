#
# Cookbook Name:: mesos
# Recipe:: slave
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'mesos::_base'
package 'docker.io'

template '/etc/init/mesos-slave.conf' do
  source 'mesos-slave.upstart.erb'
end

service 'mesos-slave' do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end
