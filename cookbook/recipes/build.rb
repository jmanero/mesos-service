#
# Cookbook Name:: mesos
# Recipe:: build
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
include_recipe 'apt::default'
include_recipe 'build-essential::default'

package 'openjdk-7-jdk'
package 'python-dev'
package 'python-boto'
package 'libcurl4-nss-dev'
package 'libsasl2-dev'
package 'maven'

%w(build build/log).each do |dir|
  directory ::File.join(node['mesos']['home'], dir) do
    owner 'vagrant'
    recursive true
  end
end

execute 'mesos-build/configure' do
  cwd ::File.join(node['mesos']['home'], 'build')
  user 'vagrant'
  command '../configure > log/configure'
  not_if { ::File.exist?(::File.join(node['mesos']['home'], 'build/Makefile')) }
end

execute 'mesos-build/make' do
  cwd ::File.join(node['mesos']['home'], 'build')
  user 'vagrant'
  command 'make -j3 > log/make'
end

execute 'mesos-build/install' do
  cwd ::File.join(node['mesos']['home'], 'build')
  command 'make install > log/install'
end
