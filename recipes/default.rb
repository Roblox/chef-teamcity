#
# Cookbook Name:: teamcity
# Recipe:: default
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
  # https://github.com/chef/chef/issues/7763
  not_if { ::File.exist?("#{home_dir}/Library/Preferences/com.apple.SetupAssistant.plist") }
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

target_dir = ::File.basename(node['teamcity']['agent']['install_dir'])
unpack_dir = ::File.dirname(node['teamcity']['agent']['install_dir'])

ark target_dir do
  url source
  path unpack_dir
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

directory ::File.join(node['teamcity']['agent']['install_dir'], 'temp') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

directory ::File.join(node['teamcity']['agent']['install_dir'], 'conf') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

properties_file = 'buildAgent.properties'
properties_path = ::File.join(node['teamcity']['agent']['install_dir'], 'conf', properties_file)

# If agent was previously authorized, re-use the token
ruby_block 'Get authorizationToken' do
  block do
    auth_token = ''
    Chef::Log.debug("Checking #{properties_file} if token already exists")
    if ::File.exist?(properties_path)
      Chef::Log.debug("TeamCity #{properties_file} file found. Reusing token.")
      auth_token = File.read(properties_path).scan(/^authorizationToken=(.*)$/).last.first
    end
    node.default['teamcity']['agent']['auth_token'] = auth_token
  end
end

# Properties to add to file. Split below to organization in file.
# `transform_keys` isn't available until Ruby 2.5
# Use lambda to delay loading of properties to allow for on-the-fly overrides in other recipes.
props_lambda = lambda {
  node['teamcity']['agent']['properties'].map { |k, v| [k.to_sym, v] }.to_h
}

# Note: This does not currently handle reloading build agent service.
# Thus, if properties file changes, the agent must be reloaded for properties to appear on server.
# Careful : as soon as a change is detected, the agent reloads on the TeamCity server
template properties_file do
  path properties_path
  source 'buildAgent.properties.erb'
  variables(
    server_url: node['teamcity']['server']['url'],
    name: node['teamcity']['agent']['name'],
    work_dir: node['teamcity']['agent']['work_dir'],
    auth_token: lazy { node['teamcity']['agent']['auth_token'] },
    opt_properties: lazy { props_lambda.call.reject { |k, _| [:env, :system].include?(k) }.flatten },
    env_properties: lazy { props_lambda.call.select { |k, _| [:env].include?(k) }.flatten },
    system_properties: lazy { props_lambda.call.select { |k, _| [:system].include?(k) }.flatten }
  )
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00644'
  only_if { !::File.exist?(properties_path) || node['teamcity']['agent']['update_properties_file'] }
end

case node['platform_family']
when 'mac_os_x'
  include_recipe 'teamcity::mac_os_x'
when 'windows'
  include_recipe 'teamcity::windows'
end

include_recipe 'teamcity::linux' if node['os'] == 'linux'
