# Change Log

## 4.3.0
* Bump homebrew vresion to ~> 5.0

## 4.2.2
* Added a workaround for DSC bug when it doesn't behave in idempotent way with an existing Windows service
* Fixed README.md (attribute listing and use `doc/`)

## 4.2.1
* Fix CVE-2018-1000201
  * Expand entries in .gitignore
  * Remove Gemfile.lock

## 4.2.0
* Update Java cookbook version with dependency fix

## 4.1.0
* Compensate for error on MacOS 10.14 (https://github.com/chef/chef/issues/7763)
* Update Java cookbook versions

## 4.0.0
* Auto-include Java
* Bump Java cookbook version

## 3.1.1
* Bump java version to ~> 2.0.1

## 3.1.0
* Generalize .kitchen.yml
* Add windows to .kitchen.yml
* Include seven_zip
* Add tests for added code

## 3.0.8
* Bump ark ~> 3.0

##3.0.7
* Bump TC server to 2017.2.4

##3.0.6
* Add service resource declaration for TCBuildAgent

##3.0.5
* Let TC Build Agent kill chef-client run, ensures that subsequent reboot requsts go through

##3.0.4
* Fix typo in LocalSystem user name

##3.0.3
* TC BuildAgent must run as LocalSystem because of file system permission issues
##3.0.2
* Use NetworkService to run TCBuildAgent
* Delay start of TCBuildAgent Service to the very end of the convergence

##3.0.1
* Fix OS X issues with `home` parameter on user resource

##3.0.0
* Adding Windows build agents

##2.2.0
* Cleanup java version attribute selection
* Bump homebrew ~> 4.2
* Bump java ~> 1.50
* Bump runit ~> 4.0

##2.1.0
* Added systemd config systemctl
* Cleanup mac_os_x recipe of hardcoded username & group

##2.0.1
* Bump Homebrew version

##2.0.0
* Major refactor and reviving of the entire cookbook
* Basic server install on Ubuntu 14 & 16 verified working
* Mac OS X El Capitan & Sierra install and auto start on boot verified
