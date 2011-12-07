require 'spec_helper'

module CampfireBot
  module AbsenteeCamper
    module Notification
      describe NotificationManager do
        let(:room) { double('room').as_null_object }
        let(:user_id) { 1 }
        let(:message) do
          {
            :person => "Chad Boyd",
            :message => "test",
            :room => room
          }
        end

        before(:all) do
          NotificationManager.send :public, :add_notifier
        end

        after(:all) do
          NotificationManager.send :private, :add_notifier
        end

        describe "creating the NotificationManager" do
          let(:prowl_api_key) { "abcde" }

          context "when the user_info is a Hash" do
            let(:user_info) do
              { 'id' => user_id }
            end

            context "and contains only one notification method" do
              before do
                user_info['notification_methods'] = { 'Prowl' => prowl_api_key }
              end

              it "creates the correct type of notifier" do
                ProwlNotifier.should_receive(:new).with(room, prowl_api_key)
                NotificationManager.new(room, user_info)
              end

              it "only creates one notifier" do
                Notification
                  .should_receive(:const_get)
                  .once
                  .and_return(ProwlNotifier)

                NotificationManager.new(room, user_info)
              end

              it "adds the notifier to the list of notifiers" do
                NotificationManager.any_instance.should_receive(:add_notifier).with(an_instance_of(ProwlNotifier))
                NotificationManager.new(room, user_info)
              end
            end

            context "and contains more than one notification method" do
              before do
                user_info['notification_methods'] = {
                  'Prowl' => prowl_api_key,
                  'Email' => user_id
                }
              end

              it "creates the correct types of notifiers" do
                ProwlNotifier.should_receive(:new).with(room, prowl_api_key)
                EmailNotifier.should_receive(:new).with(room, user_id)

                NotificationManager.new(room, user_info)
              end

              it "creates the correct number of notifiers" do
                Notification
                  .should_receive(:const_get)
                  .exactly(user_info['notification_methods'].size)
                  .times
                  .and_return(ProwlNotifier, EmailNotifier)

                NotificationManager.new(room, user_info)
              end

              it "adds the notifiers to the list of notifiers" do
                # I really don't like the way I'm testing this.  Seems
                # hacky.  I want to do something like this:
                #
                #   NotificationManager
                #     .any_instance
                #     .should_receive(:add_notifier)
                #     .once.with(an_instance_of(ProwlNotifier))
                #     .once.with(an_instance_of(EmailNotifier))
                #
                #   but, this doesn't work.

                with_prowl, with_email = false
                NotificationManager.any_instance.should_receive(:add_notifier).twice { |notifier|
                  with_prowl = true if notifier.is_a? ProwlNotifier
                  with_email = true if notifier.is_a? EmailNotifier
                }

                NotificationManager.new(room, user_info)
                with_prowl.should be_true
                with_email.should be_true
              end
            end

            context "and the user_info is not a Hash" do
              let(:user_info) { user_id }
              let(:log_message) { "No notification methods defined.  Falling back to email notifications." }

              it "logs a message" do
                Logger.instance.should_receive(:debug).with(log_message)
                NotificationManager.new(message, user_info)
              end

              it "creates an EmailNotifier by default" do
                EmailNotifier.should_receive(:new).with(room, user_info)
                NotificationManager.new(message, user_info)
              end
            end
          end
        end

        describe "sending notifications" do
          let(:user_info) do
            { 'id' => user_id }
          end
          let(:user_name) { "Chad" }
          let(:formatted_message) { "#{message[:person]} says: #{message[:message]}" }

          context "when there is only one notifier" do
            before do
              user_info['notification_methods'] = { 'Prowl' => 'abcde' }
            end

            it "only sends one notification" do
              ProwlNotifier.any_instance.should_receive(:notify)
              manager = NotificationManager.new(message, user_info)
              manager.send_notifications
            end
          end

          context "when there are multiple notifiers" do
            before do
              user_info['notification_methods'] = {
                'Prowl' => 'abcde',
                'Email' => user_id
              }
            end

            it "only sends one notification" do
              ProwlNotifier.any_instance.should_receive(:notify)
              EmailNotifier.any_instance.should_receive(:notify)
              manager = NotificationManager.new(message, user_info)
              manager.send_notifications
            end
          end

          it "sends the correct message" do
            EmailNotifier.any_instance.should_receive(:notify).with(formatted_message)
            manager = NotificationManager.new(message, user_id)
            manager.send_notifications
          end
        end
      end
    end
  end
end
