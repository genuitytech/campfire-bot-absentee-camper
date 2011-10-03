require 'spec_helper'

module CampfireBot
  module AbsenteeCamper
    module Notification
      describe EmailNotifier do

        let(:email_address) { "johnny@test.com" }
        let(:uri) { 'http://www.google.com' }
        let(:body) do
          body = <<-BODY
Come back to the campfire!  We're having a good time telling ghost stories!  Here's one you missed:

#{message}

#{uri}
BODY
        end
        let(:message) { "this is a test" }
        let(:user_id) { 1 }
        let(:email_address) { 'jon.levin@shredders-r-us.com' }
        let(:room) do
          room = double('room').as_null_object
          room.stub(:user).with(user_id).and_return({ 'email_address' => email_address })
          room
        end
        let(:pony_options) { { :via => :smtp } }

        before do
          subject.stub(:room_uri).and_return(uri)
          EmailNotifier.any_instance.stub(:room_uri).and_return(uri)
        end

        describe :notify do
          subject { EmailNotifier.new(room, user_id) }

          before do
            subject.stub(:plugin_config).and_return({'pony_options' => pony_options })
          end

          it "logs a message indicating the message is being sent" do
            Pony.stub(:mail)
            Logger.instance.should_receive(:debug).with("sending email to #{email_address}")
            subject.notify(message)
          end

          it "sends the email with the correct information" do
            Pony.should_receive(:mail).with({
              :to => email_address,
              :body => body
            }.merge(pony_options))

            subject.notify(message)
          end
        end
      end
    end
  end
end
