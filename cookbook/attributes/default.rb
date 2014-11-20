#
# Cookbook Name:: mesos
# Attributes:: default
#
# The MIT License (MIT)
# Copyright (c) 2014 John Manero <john.manero@gmail.com>
#

## Zookeeper
default['zookeeper']['config']['tickTime'] = 2000
default['zookeeper']['config']['dataDir'] = '/var/zookeeper'
default['zookeeper']['config']['clientPort'] = 2181
default['zookeeper']['config']['initLimit'] = 5
default['zookeeper']['config']['syncLimit'] = 2

default['zookeeper']['logs'] = '/var/log/zookeeper'
default['zookeeper']['quorum_port'] = 2888
default['zookeeper']['election_port'] = 3888

## Mesos
default['mesos']['home'] = '/opt/mesos'
default['mesos']['logs'] = '/var/log/mesos'
default['mesos']['data'] = '/var/mesos'
default['mesos']['cluster_name'] = 'default'
default['mesos']['log_level'] = 'INFO'

## Singularity
default['singularity']['port'] = 7099
default['singularity']['home'] = '/opt/singularity'
default['singularity']['log'] = '/var/log/singularity'
default['singularity']['bin'] = '/usr/local/singularity/bin'
default['singularity']['database']['host'] = 'localhost'
default['singularity']['database']['port'] = 3306
default['singularity']['database']['user'] = 'singularity'
default['singularity']['database']['name'] = 'singularity'
