#
# Cookbook Name:: teamcity
# Attribute:: default
#
# Copyright (C) 2016 Antek S. Baranski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# TeamCity Server Attributes
default['teamcity']['server']['source_url'] = 'https://download.jetbrains.com/teamcity/TeamCity-10.0.2.tar.gz'
default['teamcity']['server']['checksum'] = '35abb03ed176c8326adc86cac17a93412c7248277d9aae422b89be17edff8f97'
default['teamcity']['server']['url'] = 'http://localhost:8111'
default['teamcity']['server']['port'] = '8111'
default['teamcity']['server']['user'] = 'teamcity'
default['teamcity']['server']['group'] = 'users'
default['teamcity']['server']['install_dir'] = '/opt'
default['teamcity']['server']['pid_file'] = '/usr/local/teamcity-server/logs/catalina.pid'
default['teamcity']['server']['data_path'] = '/var/teamcity-server/data'

# TeamCity Agent Attributes
default['teamcity']['agent']['install_dir'] = '/opt'
default['teamcity']['agent']['work_dir'] = '/var/teamcity-agent'
default['teamcity']['agent']['name'] = node['hostname']
default['teamcity']['agent']['user'] = 'teamcity'
default['teamcity']['agent']['uid'] = 1023 if platform_family?('mac_os_x')
default['teamcity']['agent']['group'] = platform_family?('mac_os_x') ? 'staff' : 'users'
default['teamcity']['agent']['home'] = platform_family?('mac_os_x') ? '/Users' : '/home'

# NOTE: Brew does not tag the latest java version with an ID, therefore we must 'nil' it to get the latest.
default['java']['jdk_version'] = platform_family?('mac_os_x') ? '' : '8'
