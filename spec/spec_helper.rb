require "rubygems"
require "bundler/setup"
Bundler.require(:default, :test)

BOT_ROOT = File.join(FileUtils.pwd, 'spec')
BOT_ENVIRONMENT = 'test'
require 'bot'
require 'absentee_camper'

RSpec.configure do |config|
  config.include CampfireBot::AbsenteeCamper::Notification
  config.include CampfireBot::AbsenteeCamper::Config
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before do
    CampfireBot::AbsenteeCamper::Logger.stub(:instance).and_return(double('logger').as_null_object)
  end
end
