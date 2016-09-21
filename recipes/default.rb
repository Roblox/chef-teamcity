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

user node['teamcity']['agent']['user'] do
  uid node['teamcity']['agent']['uid']
  action :create
end

group node['teamcity']['agent']['group'] do
  append true
  members [node['teamcity']['agent']['user']]
  action :create
end

unless platform_family?('windows')
  root_dir = ::File.join(node['teamcity']['agent']['install_dir'], 'teamcity-agent')

  source = if node['teamcity']['agent']['source_url']
             node['teamcity']['agent']['source_url']
           else
             "#{node['teamcity']['server']['url']}/update/buildAgent.zip"
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
end

case node['platform_family']
when 'mac_os_x'
  include_recipe 'teamcity::mac_os_x'
when 'windows'
  include_recipe 'teamcity::windows'
end
