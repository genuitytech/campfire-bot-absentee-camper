require 'spec_helper'

module CampfireBot
  module AbsenteeCamper
    module Notification
      describe ProwlNotifier do
        let(:api_key) { '123456789' }
        let(:application) { 'Campfire' }
        let(:event) { 'Mentioned' }
        let(:message) { 'testing 1 2 3' }
        let(:uri) { 'http://www.google.com' }
        let(:room) do
          room = double('room').as_null_object
          room.stub(:name).and_return(event)
          room
        end

        subject { ProwlNotifier.new(room, api_key) }

        before do
          subject.stub(:room_uri).and_return(uri)
        end

        describe :notify do

          it "logs a message indicating the message is being sent" do
            Prowl.stub(:add)
            Logger.instance.should_receive(:debug).with('sending prowl notification')
            subject.notify(message)
          end

          it "sends the Prowl message" do
            Prowl.should_receive(:add).with({
              :apikey => api_key,
              :application => application,
              :event => event,
              :description => message,
              :url => uri
            })

            subject.notify(message)
          end
        end
      end
    end
  end
end
