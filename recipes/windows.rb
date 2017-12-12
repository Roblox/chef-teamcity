#
# Cookbook Name:: teamcity
# Recipe:: windows
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

# Do not run this recipe if the node is not a MS Windows node
return unless platform_family?('windows')

# Setup TemaCity Build Agent as a service.
# NOTE: The Name, DisplayName & Description MUST not change, they are tied to the the wrapper.conf script that comes
# with the TeamCity Build Agent zip file.
dsc_resource 'TeamCity BuildAgent Service' do
  action :nothing
  resource :service
  property :name, 'TCBuildAgent'
  property :ensure, 'Present'
  property :builtinaccount, 'Local System'
  property :startuptype, 'Automatic'
  property :state, 'Running'
  property :description, 'TeamCity Build Agent Service'
  property :displayname, 'TeamCity Build Agent'
  property :path, "#{node['teamcity']['agent']['work_dir']}\\launcher\\bin\\TeamCityAgentService-windows-x86-32.exe -s #{node['teamcity']['agent']['work_dir']}\\launcher\\conf\\wrapper.conf"
end

# This block ensures that the TeamCity BuildAgent Service is created at the very end of the convergense, such that any
# paths and other ENV variables are picked up by the service when it starts
ruby_block 'Setup TeamCity BuildAgent Service' do
  block do
    true
  end
  notifies :run, 'dsc_resource[TeamCity BuildAgent Service]', :delayed
end
