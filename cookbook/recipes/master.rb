#
# Cookbook Name:: mesos
# Recipe:: master
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'mesos::_base'

directory node['mesos']['data'] do
  owner 'mesos'
end

template '/etc/init/mesos-master.conf' do
  source 'mesos-master.upstart.erb'
  notifies :stop, 'service[mesos-master]'
  notifies :start, 'service[mesos-master]'
end

service 'mesos-master' do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end
