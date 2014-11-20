#
# Cookbook Name:: mesos
# Recipe:: _base
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'apt::default'

group 'mesos' do
  system true
end

user 'mesos' do
  system true
  home node['mesos']['home']
  group 'mesos'
end

[node['mesos']['home'], node['mesos']['logs']].each do |dir|
  directory dir do
    owner 'mesos'
  end
end
