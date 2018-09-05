require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
end

def get_runner(platform, version)
  runner = ChefSpec::ServerRunner.new(platform: platform, version: version)

  yield runner if block_given?

  runner
end
