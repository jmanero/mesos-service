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
  directory ::File.join('/opt/mesos/', dir) do
    owner 'vagrant'
    recursive true
  end
end

execute 'mesos-build/configure' do
  cwd '/opt/mesos/build'
  user 'vagrant'
  command '../configure > log/configure'
  not_if { ::File.exist?('/opt/mesos/build/Makefile') }
end

execute 'mesos-build/make' do
  cwd '/opt/mesos/build'
  user 'vagrant'
  command 'make -j3 > log/make'
end

execute 'mesos-build/install' do
  cwd '/opt/mesos/build'
  command 'make install > log/install'
end
