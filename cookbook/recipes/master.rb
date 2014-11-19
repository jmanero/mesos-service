#
# Cookbook Name:: mesos
# Recipe:: build
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'apt::default'

template '/etc/init/mesos-master.conf' do
  source 'mesos-master.upstart.erb'
end

service 'mesos-master' do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end
