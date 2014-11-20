#
# Cookbook Name:: mesos
# Attributes:: singularity
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#
package 'git'
package 'maven'
package 'nodejs'
package 'npm'
link '/usr/bin/node' do
  to '/usr/bin/nodejs'
end

group 'singularity' do
  system true
end
user 'singularity' do
  group 'singularity'
  system true
  home node['singularity']['home']
end

execute 'singularity/extract' do
  command 'tar -xzf /opt/singularity.tar.gz --strip 1'
  cwd node['singularity']['home']
  action :nothing
end

directory node['singularity']['home'] do
  owner 'singularity'
  recursive true
  notifies :run, 'execute[singularity/extract]', :immediate
end

['/etc/singularity',
 node['singularity']['log'],
 node['singularity']['bin']].each do |dir|
  directory dir do
    owner 'singularity'
    recursive true
  end
end

template '/etc/singularity/singularity.yaml' do
  source 'singularity.yaml.erb'
  notifies :restart, 'service[singularity]'
end

template '/etc/init/singularity.conf' do
  source 'singularity.upstart.erb'
  notifies :stop, 'service[singularity]'
  notifies :start, 'service[singularity]'
end

###
## Maven Build
###
singularity_build_jar = ::File.join(
  node['singularity']['home'],
  'SingularityService/target/SingularityService-0.4.0-SNAPSHOT-shaded.jar'
)
singularity_jar = ::File.join(
  node['singularity']['bin'],
  'singularity.jar'
)

execute 'singularity/make' do
  command 'mvn clean package -DskipTests > maven-build.log'
  env 'HOME' => node['singularity']['home']
  user 'singularity'
  cwd node['singularity']['home']
  not_if { ::File.exist?(singularity_build_jar) }
end

execute 'singularity/install' do
  command "cp #{ singularity_build_jar } #{ singularity_jar }"
  cwd node['singularity']['home']
  not_if { ::File.exist?(singularity_jar) }
  only_if { ::File.exist?(singularity_build_jar) }
end

execute 'singularity/migrate' do
  command "java -jar #{ singularity_jar } db migrate "\
          '/etc/singularity/singularity.yaml --migrations '\
          "#{ node['singularity']['home'] }/mysql/migrations.sql"
  cwd node['singularity']['home']
  action :nothing
end

###
##  Set up a local MySQL instance for testing
###
require 'securerandom'
include_recipe 'database::mysql'

## Generate a random database password
root_passwd_file = ::File.join(Chef::Config['cache_path'], 'root-db-password')
singularity_passwd_file = ::File.join(Chef::Config['cache_path'], 'singularity-db-password')

[root_passwd_file, singularity_passwd_file].each do |file|
  next if ::File.exist?(file)

  Chef::Log.info("Writing random password to #{ file }")
  IO.write(file, SecureRandom.urlsafe_base64(36))
end

## Read Stored Passwords
root_db_pass = IO.read(root_passwd_file)
node.default['singularity']['database']['password'] = IO.read(singularity_passwd_file)

mysql_service 'singularity' do
  version '5.6'
  port node['singularity']['database']['port'].to_s
  data_dir '/var/mysql'
  allow_remote_root false
  root_network_acl ['192.168.33/24']
  remove_anonymous_users true
  remove_test_database true
  server_root_password root_db_pass
  enable_utf8 'true'
  action :create
end

mysql_database node['singularity']['database']['name'] do
  connection(
    :host     => node['singularity']['database']['host'],
    :username => 'root',
    :password => root_db_pass
  )
  action :create
end

mysql_database_user node['singularity']['database']['user'] do
  connection(
    :host     => node['singularity']['database']['host'],
    :username => 'root',
    :password => root_db_pass
  )
  password node['singularity']['database']['password']
  database_name node['singularity']['database']['name']
  host '%'
  privileges [:all]
  action :grant
  notifies :run, 'execute[singularity/migrate]', :immediate
end

service 'singularity' do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end
