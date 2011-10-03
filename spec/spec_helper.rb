require "rubygems"
require "bundler/setup"
Bundler.require(:default, :test)

BOT_ROOT = '..'
BOT_ENVIRONMENT = 'test'
require 'bot'
require 'absentee_camper'

RSpec.configure do |config|
  config.before do
    CampfireBot::AbsenteeCamper::Logger.stub(:instance).and_return(double('logger').as_null_object)
  end
end
