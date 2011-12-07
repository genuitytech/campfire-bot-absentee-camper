module CampfireBot
  module AbsenteeCamper
    module Notification
      class NotificationManager

        def initialize(message, user_config)
          @message = message
          room = message[:room]

          if user_config.is_a?(Hash) and user_config['notification_methods']
            user_config['notification_methods'].each do |notifier, initialization_info|
              add_notifier Notification.const_get("#{notifier}Notifier".to_sym).new(room, initialization_info)
            end
          else
            # Everyone gets Email notifications if no other notifier is defined.
            # In this case, user_config is the user_id.

            Logger.instance.debug "No notification methods defined.  Falling back to email notifications."
            @notifiers = [EmailNotifier.new(room, user_config)]
          end
        end

        def send_notifications
          @notifiers.each { |notifier| notifier.notify format_message(@message) }
        end

        private

        def format_message(message)
          "#{message[:person]} says: #{message[:message]}"
        end

        def add_notifier(notifier)
          @notifiers ||= []
          @notifiers << notifier
        end
      end
    end
  end
end
