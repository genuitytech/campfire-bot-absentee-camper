module CampfireBot
  module AbsenteeCamper
    autoload :Config, "absentee_camper/config"
    autoload :Logger, "absentee_camper/logger"
    autoload :NotificationManager, "absentee_camper/notification/notification_manager"

    module Notification
      autoload :EmailNotifier, "absentee_camper/notification/email_notifier"
      autoload :ProwlNotifier, "absentee_camper/notification/prowl_notifier"
    end

    class Plugin < CampfireBot::Plugin
      include Notification
      include Config

      on_message /@\w+/i, :role_call

      def initialize
        Logger.instance.log = bot.log
      end

      def role_call(msg)
        room = msg[:room]

        body = msg['body']
        body.scan(/@\w+/).map(&:downcase).uniq.each do |mention|
          mentioned = mention[1..-1]
          if plugin_config['users'].keys.include? mentioned

            # If the user isn't in the room, fire off a notification
            unless room.users.map { |u| u['id'] }.include? user_id_from_config(mentioned)
              NotificationManager.new(msg, plugin_config['users'][mentioned]).send_notifications
              room.speak("[Notified #{mentioned}]")
            end
          end
        end
      end

      private

      def user_id_from_config(mentioned)
        if plugin_config['users'][mentioned].is_a? Hash
          plugin_config['users'][mentioned]['id']
        else
          plugin_config['users'][mentioned]
        end
      end
    end

    module Helpers
      def room_uri(room)
        "https://#{root_config['site']}.campfirenow.com/room/#{room.id}"
      end
    end
  end
end
