name             'teamcity'
maintainer       'Antek S. Baranski'
maintainer_email 'antek.baranski@gmail.com'
license          'Apache License, Version 2.0'
description      'Installs TeamCity server and agent'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.3'

recipe 'teamcity::default', 'Installs TeamCity Agent on target OS'
recipe 'teamcity::server', 'Installs TeamCity Server on CentOS or Ubuntu'

supports 'mac_os_x'
supports 'ubuntu'
supports 'centos'

depends 'ark', '~> 2.0'
depends 'homebrew', '~> 4.2'
depends 'java', '~> 1.50'
depends 'runit', '~> 4.0'
depends 'systemd'
