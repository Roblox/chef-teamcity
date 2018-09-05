require_relative '../spec_helper'

describe 'teamcity::default' do
  describe 'windows' do
    let(:platform) { 'windows' }
    let(:version) { '2016' }
    let(:runner) { get_runner(platform, version) }

    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    describe '7z' do
      it 'includes the 7z recipe' do
        # for some reason (probably the way Chef::Node is implemented, `be_true`
        # doesn't work here
        expect(chef_run.node['seven_zip']['syspath']).to be_truthy
        expect(chef_run).to include_recipe('seven_zip::default')
      end
    end

    describe 'build agent service' do
      context 'when startuptype is Manual' do
        cached(:chef_run) do
          runner.node.normal['teamcity']['agent']['windows_service']['startuptype'] = 'Manual'
          runner.converge(described_recipe)
        end

        it 'defines the service as Manual and Stopped' do
          # annoyingly, chefspec implements their matchers without support for
          # `hash_including` so we have to match all the properties event though
          # we're only interested in two of them
          expect(chef_run).to run_dsc_resource('Setup TeamCity BuildAgent Service').with(
            properties: {
              name: 'TCBuildAgent',
              ensure: 'Present',
              builtinaccount: 'LocalSystem',
              startuptype: 'Manual',
              state: 'Stopped',
              description: 'TeamCity Build Agent Service',
              displayname: 'TeamCity Build Agent',
              path: "#{chef_run.node['teamcity']['agent']['work_dir']}\\launcher\\bin\\TeamCityAgentService-windows-x86-32.exe -s #{chef_run.node['teamcity']['agent']['work_dir']}\\launcher\\conf\\wrapper.conf",
            }
          )
        end
      end

      context 'when startuptype is Automatic' do
        it 'defines the service as Automatic and Running' do
          expect(chef_run).to run_dsc_resource('Setup TeamCity BuildAgent Service').with(
            properties: {
              name: 'TCBuildAgent',
              ensure: 'Present',
              builtinaccount: 'LocalSystem',
              startuptype: 'Automatic',
              state: 'Running',
              description: 'TeamCity Build Agent Service',
              displayname: 'TeamCity Build Agent',
              path: "#{chef_run.node['teamcity']['agent']['work_dir']}\\launcher\\bin\\TeamCityAgentService-windows-x86-32.exe -s #{chef_run.node['teamcity']['agent']['work_dir']}\\launcher\\conf\\wrapper.conf",
            }
          )
        end
      end
    end
  end
end
