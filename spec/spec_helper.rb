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

  config.before do
    CampfireBot::AbsenteeCamper::Logger.stub(:instance).and_return(double('logger').as_null_object)
  end
end
