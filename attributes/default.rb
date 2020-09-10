#
# Cookbook Name:: teamcity
# Attribute:: default
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
default['teamcity']['server']['source_url'] = 'https://download.jetbrains.com/teamcity/TeamCity-2020.1.3.tar.gz'
default['teamcity']['server']['checksum'] = '8d21480da9392709efd6dd6cb7b513211a45e462909799b5b880e36def1522fc'
default['teamcity']['server']['url'] = 'http://localhost:8111'
default['teamcity']['server']['port'] = '8111'
default['teamcity']['server']['user'] = 'teamcity'
default['teamcity']['server']['group'] = 'users'
default['teamcity']['server']['install_dir'] = '/opt'
default['teamcity']['server']['pid_file'] = '/usr/local/teamcity-server/logs/catalina.pid'
default['teamcity']['server']['data_path'] = '/var/teamcity-server/data'

# TeamCity Agent Attributes
# <> Install directory for agent
default['teamcity']['agent']['install_dir'] = platform_family?('windows') ? 'C:\\teamcity-agent\\' : '/opt/teamcity-agent'
default['teamcity']['agent']['work_dir'] = platform_family?('windows') ? 'C:\\teamcity-agent' : '/var/teamcity-agent'
default['teamcity']['agent']['name'] = node['hostname']
default['teamcity']['agent']['user'] = 'teamcity'
default['teamcity']['agent']['uid'] = 1023 if platform_family?('mac_os_x')
default['teamcity']['agent']['group'] = platform_family?('mac_os_x') ? 'staff' : 'users'
default['teamcity']['agent']['home'] = case node['platform_family']
                                       when 'mac_os_x'
                                         '/Users'
                                       when 'windows'
                                         'C:\Users'
                                       else
                                         '/home'
                                       end

# <> Update preoprties file after it's been installed
# Default to false for backwards compabitility where it would not update if already exists.
# Note: This does not effect the initial install of the file
default['teamcity']['agent']['update_properties_file'] = false

# <> Two dimensional has of additional properties that are added to conf/buildAgent.properties file
default['teamcity']['agent']['properties'] = {
  env: {},
  system: {},
}

default['teamcity']['agent']['stdout_path'] = '/dev/null'
default['teamcity']['agent']['launch_command'] = 'bin/agent.sh run'

default['teamcity']['agent']['windows_service']['startuptype'] = 'Automatic'
default['teamcity']['ignore_dsc_errors'] = true

# NOTE: Brew does not tag the latest java version with an ID, therefore we must 'nil' it to get the latest.
default['java']['jdk_version'] = platform_family?('mac_os_x') ? '' : '8'
default['java']['windows']['url'] = nil
default['java']['windows']['package_name'] = 'Java SE Development Kit 8 Update 152 (64-bit)'
default['java']['windows']['checksum'] = nil
