#
# Cookbook Name:: teamcity
# Recipe:: mac_os_x
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

# Do not run this recipe if the node is not a MAC OSX node
return unless platform_family?('mac_os_x')

# Used to escape shell parameters.
require 'shellwords'
# Generate random password string
require 'securerandom'
password = SecureRandom.base64(16)

# Used for auto-login password
cookbook_file '/usr/local/bin/enable_autologin.sh' do
  source 'enable_autologin.sh'
  owner 'root'
  group 'admin'
  mode '0755'
  action :create
end

home_dir = ::File.join(node['teamcity']['agent']['home'], node['teamcity']['agent']['user'])

# NOTE: We assume the user got created if the
# #{home_dir}/Library/Preferences/com.apple.SetupAssistant.plist file exists.
bash 'Create Mac OS X teamcity agent user' do
  code <<-EOH
    #!/bin/sh
    . /etc/rc.common
    /usr/bin/dscl . -create #{home_dir}
    /usr/bin/dscl . -create #{home_dir} UserShell /bin/bash
    /usr/bin/dscl . -create #{home_dir} RealName "TeamCity BuildAgent"
    /usr/bin/dscl . -create #{home_dir} UniqueID "#{node['teamcity']['agent']['uid']}"
    /usr/bin/dscl . -create #{home_dir} PrimaryGroupID 20
    /usr/bin/dscl . -create #{home_dir} NFSHomeDirectory #{home_dir}
    /usr/bin/dscl . -passwd #{home_dir} #{Shellwords.escape(password)}
    /usr/sbin/createhomedir -c -u #{node['teamcity']['agent']['user']}
    sw_vers=$(sw_vers -productVersion)
    sw_build=$(sw_vers -buildVersion)
    mkdir -p #{home_dir}/Library/Preferences
    #{node['teamcity']['agent']['mac_os_x']['setup_assistant'].map do |k, v|
        "/usr/bin/defaults write #{home_dir}/Library/Preferences/com.apple.SetupAssistant #{k} #{v}"
      end.join("\n")}
    /usr/bin/defaults write #{home_dir}/Library/Preferences/com.apple.SetupAssistant LastPreLoginTasksPerformedBuild "${sw_build}"
    /usr/bin/defaults write #{home_dir}/Library/Preferences/com.apple.SetupAssistant LastPreLoginTasksPerformedVersion "${sw_vers}"
    /usr/bin/defaults write #{home_dir}/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write #{home_dir}/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/sbin/chown -R #{node['teamcity']['agent']['user']}:#{node['teamcity']['agent']['group']} #{home_dir}
    /usr/local/bin/enable_autologin.sh -u #{node['teamcity']['agent']['user']} -p #{Shellwords.escape(password)}
    if [ $? -ne 0 ]; then
      echo "ERROR! Problem setting auto-login info!"
      exit 1
    fi
  EOH
  sensitive true
  not_if { ::File.exist?("#{home_dir}/Library/Preferences/com.apple.SetupAssistant.plist") }
  notifies :request_reboot, 'reboot[Reboot System]', :immediately
end

directory ::File.join(home_dir, 'Library') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00700'
  action :create
end

directory ::File.join(home_dir, 'Library', 'LaunchAgents') do
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
  action :create
end

template ::File.join(home_dir, 'Library', 'LaunchAgents', 'jetbrains.teamcity.BuildAgent.plist') do
  source 'jetbrains.teamcity.BuildAgent.plist.erb'
  variables(
    launch_command: node['teamcity']['agent']['launch_command'],
    stdout_path: node['teamcity']['agent']['stdout_path'],
    working_dir: node['teamcity']['agent']['install_dir']
  )
  owner node['teamcity']['agent']['user']
  group node['teamcity']['agent']['group']
  mode '00755'
end

reboot 'Reboot System' do
  action :nothing
  delay_mins 1
end
