name             'teamcity'
maintainer       'Roblox'
maintainer_email 'info@roblox.com'
license          'Apache-2.0'
description      'Installs TeamCity server and agent'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.3.0'

source_url 'https://github.com/Roblox/chef-teamcity'
issues_url 'https://github.com/Roblox/chef-teamcity/issues'
chef_version '>= 13.4'

recipe 'teamcity::default', 'Installs TeamCity Agent on target OS'
recipe 'teamcity::server', 'Installs TeamCity Server on CentOS or Ubuntu'

supports 'mac_os_x'
supports 'ubuntu'
supports 'centos'

depends 'ark', '~> 3.0'
depends 'homebrew', '~> 5.0'
depends 'java', '~> 4.0'
depends 'runit', '~> 4.0'
depends 'seven_zip'
depends 'systemd'
