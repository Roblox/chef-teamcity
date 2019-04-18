#
# Cookbook Name:: teamcity
# Recipe:: server
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

include_recipe 'java'

user node['teamcity']['server']['user'] do
  action :create
  home "/home/#{node['teamcity']['server']['user']}"
  manage_home true
end

group node['teamcity']['server']['group'] do
  append true
  members [node['teamcity']['server']['user']]
  action :create
end

directory node['teamcity']['server']['data_path'] do
  owner node['teamcity']['server']['user']
  group node['teamcity']['server']['group']
  mode 00755
  recursive true
  action :create
end

service 'teamcity-server' do
  supports start: true, stop: true, restart: true
  action :nothing
end

ark 'teamcity-server' do
  url node['teamcity']['server']['source_url']
  checksum node['teamcity']['server']['checksum']
  path node['teamcity']['server']['install_dir']
  strip_components 1
  owner node['teamcity']['server']['user']
  group node['teamcity']['server']['group']
  action :put
end

template '/etc/init.d/teamcity-server' do
  source 'teamcity-server.init.erb'
  mode 0755
  variables data_path: node['teamcity']['server']['data_path'],
            pid_file: node['teamcity']['server']['pid_file'],
            path: "#{node['teamcity']['server']['install_dir']}/teamcity-server",
            user: node['teamcity']['server']['user']
  notifies :enable, 'service[teamcity-server]'
  notifies :restart, 'service[teamcity-server]'
end
