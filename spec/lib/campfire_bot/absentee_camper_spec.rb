require 'spec_helper'

module CampfireBot
  module AbsenteeCamper
    include Notification

    describe Plugin do
      describe :role_call do
        let(:users_in_config) { plugin_config['users'] }
        let(:user_names_in_config) { users_in_config.keys }
        let(:user_name_not_in_config) do
          if user_names_in_config.include?(user_name = 'joel')
            raise "User name expected to not be in config is present"
          end

          user_name
        end

        let(:room) do
          room = double('room')

          # No users present in room by default
          room.stub(:users).and_return([])
          room.stub(:speak)
          room
        end

        let(:message) do
          {
            :room => room,

            # @mentions can be added to body as needed
            'body' => body_without_mention
          }
        end
        let(:body_without_mention) { "hey there!" }
        let(:notification_manager) { double("notification manager") }

        it "notifies people that are @mentioned" do
          user_name = user_names_in_config.first
          add_users_to_message user_name

          sends_notification_to user_name
          subject.role_call message
        end

        it "doesn't send notifications to people that aren't mentioned" do
          add_users_to_message user_name_not_in_config

          does_not_send_notification
          subject.role_call message
        end

        context "when @mentioning a user that is present in the room" do
          let(:user_in_room) { user_names_in_config.first }

          before do
            room.stub(:users).and_return([{ 'id' => users_in_config.values.first['id'] }])
          end

          it "doesn't send a notification" do
            add_users_to_message user_in_room
            subject.role_call message
          end
        end

        it "is case-insenstive to @mentions" do
          user_name = user_names_in_config.first

          mixed_case = user_name[0].upcase + user_name[1..-1]
          add_users_to_message mixed_case
          sends_notification_to user_name
          subject.role_call message

          reset_message_body

          add_users_to_message user_name.upcase
          sends_notification_to user_name
          subject.role_call message
        end

        context "when multiple users are @mentioned" do
          before do
            add_users_to_message *user_names_in_config
          end

          it "sends a notification to each user @mentioned" do
            times = 0
            user_names_in_config.each do |name|
              times += 1

              NotificationManager
                .should_receive(:new)
                .with(message, users_in_config[name])
                .and_return(notification_manager)
            end

            notification_manager.should_receive(:send_notifications).exactly(times).times
            subject.role_call message
          end
        end

        context "when the same user is @mentioned multiple times" do
          let(:name) { user_names_in_config.first }

          before do
            # use different variations in case also
            same_names = [name, name.upcase]
            add_users_to_message *same_names
          end

          it "only sends one notification" do
            sends_notification_to name
            subject.role_call message
          end
        end

        def reset_message_body
          message['body'] = body_without_mention
        end

        def add_users_to_message(*users)
          message['body'] = "#{mentionize_users(users)} #{message['body']}"
        end

        def mentionize_users(users)
          users.map { |user| "@#{user}" }.join(' ')
        end

        def sends_notification_to(name)
          NotificationManager
            .should_receive(:new)
            .with(message, users_in_config[name])
            .and_return(notification_manager)

          notification_manager.should_receive(:send_notifications)
        end

        def does_not_send_notification
          NotificationManager.should_not_receive(:new)
          NotificationManager.any_instance.should_not_receive(:send_notifications)
        end
      end
    end
  end
end
