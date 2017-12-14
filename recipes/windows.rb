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

# Setup TemaCity Build Agent as a service, this kill the chef-client run on first time as the TC Build Agent disconnects
# immediately from the server to upgrade which causes this resource to fail.
# NOTE: The Name, DisplayName & Description MUST not change, they are tied to the the wrapper.conf script that comes
# with the TeamCity Build Agent zip file.
dsc_resource 'Setup TeamCity BuildAgent Service' do
  resource :service
  property :name, 'TCBuildAgent'
  property :ensure, 'Present'
  property :builtinaccount, 'LocalSystem'
  property :startuptype, 'Automatic'
  property :state, 'Running'
  property :description, 'TeamCity Build Agent Service'
  property :displayname, 'TeamCity Build Agent'
  property :path, "#{node['teamcity']['agent']['work_dir']}\\launcher\\bin\\TeamCityAgentService-windows-x86-32.exe -s #{node['teamcity']['agent']['work_dir']}\\launcher\\conf\\wrapper.conf"
end

# We declare this here such that downstream dependencies can restart the service to pick up ENV variables.
service 'TCBuildAgent' do
  action :nothing
end
