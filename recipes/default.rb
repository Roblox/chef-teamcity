#
# Cookbook Name:: teamcity
# Recipe:: default
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

home_dir = ::File.join(node['teamcity']['agent']['home'], node['teamcity']['agent']['user'])

# The `home` parameter even when set throws an nil exception when converging on OS X.
# TODO: Figure out why `home` is nil on OS X.
user node['teamcity']['agent']['user'] do
  uid node['teamcity']['agent']['uid'] if platform_family?('mac_os_x')
  home home_dir unless platform_family?('mac_os_x')
  manage_home true
  action :create
end

group node['teamcity']['agent']['group'] do
  append true
  members [node['teamcity']['agent']['user']]
  action :create
end

directory home_dir do
  action :create
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
end

root_dir = ::File.join(node['teamcity']['agent']['install_dir'], 'teamcity-agent')

source = node['teamcity']['agent']['source_url']
source = "#{node['teamcity']['server']['url']}/update/buildAgent.zip" if source.nil?

if platform_family?('windows')
  node.default['seven_zip']['syspath'] = true
  include_recipe 'seven_zip::default'
end

if platform_family?('windows')
  include_recipe 'java::windows'
else
  include_recipe 'java'
end

ark 'teamcity-agent' do
  url source
  path node['teamcity']['agent']['install_dir']
  strip_components 0
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  action :put
end

directory node['teamcity']['agent']['work_dir'] do
  recursive true
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

directory ::File.join(node['teamcity']['agent']['work_dir'], 'logs') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

directory ::File.join(root_dir, 'temp') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

directory ::File.join(root_dir, 'conf') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

template ::File.join(root_dir, 'conf', 'buildAgent.properties') do
  source 'buildAgent.properties.erb'
  variables serverurl: node['teamcity']['server']['url'],
            name: node['teamcity']['agent']['name'],
            work_dir: node['teamcity']['agent']['work_dir']
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00644'
  only_if do
    if ::File.exist?(::File.join(root_dir, 'conf', 'buildAgent.properties'))
      ::File.foreach(::File.join(root_dir, 'conf', 'buildAgent.properties')).grep(/authorizationToken=$/).any?
    else
      true
    end
  end
end

case node['platform_family']
when 'mac_os_x'
  include_recipe 'teamcity::mac_os_x'
when 'windows'
  include_recipe 'teamcity::windows'
end

include_recipe 'teamcity::linux' if node['os'] == 'linux'
