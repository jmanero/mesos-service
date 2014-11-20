#
# Cookbook Name:: mesos
# Recipe:: slave
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'mesos::_base'
package 'docker.io'

group 'docker' do
  action :manage
  append true
  members 'mesos'
end

template '/etc/init/mesos-slave.conf' do
  source 'mesos-slave.upstart.erb'
  notifies :stop, 'service[mesos-slave]'
  notifies :start, 'service[mesos-slave]'
end

service 'mesos-slave' do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end
