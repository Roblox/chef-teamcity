#
# Cookbook Name:: teamcity
# Recipe:: linux
#
# Copyright (C) 2017 Antek S. Baranski
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

# Do not run this recipe if the node is not a Linux node
return unless node['os'] == 'linux'

root_dir = ::File.join(node['teamcity']['agent']['install_dir'], 'teamcity-agent')

systemd_service 'teamcity_agent' do
  unit_description 'TeamCity Agent'
  after 'network.target'

  install do
    wanted_by 'multi-user.target'
  end

  service do
    type 'forking'
    exec_start ::File.join(root_dir, 'bin', 'agent.sh start')
    exec_stop ::File.join(root_dir, 'bin', 'agent.sh stop')
    pid_file ::File.join(root_dir, 'logs', 'buildAgent.pid')
    syslog_identifier 'teamcity_agent'
    restart 'on-failure'
    restart_sec 5
    user node['teamcity']['agent']['user']
    group node['teamcity']['agent']['group']
    private_tmp true
    remain_after_exit true
    action [:create, :enable, :start]
  end
end
