# NOTE

Currently, this only works with [my fork](https://github.com/hoverlover/campfire-bot).  Hopefully,
the maintainers of the [main repo](https://github.com/joshwand/campfire-bot) will pull in my changes.

#CampfireBot::AbsenteeCamper

This is a plugin for use with [campfire-bot](https://github.com/joshwand/campfire-bot).
It will monitor a Campfire room for _@mentions_, and notify the
mentioned users using one of the built-in notifiers (email by default)
if they aren't present in the room.  Multiple users
can be mentioned in one Campfire message, and each user will receive one
notification.  The notification will contain the message that was
triggered by the _@mention_.

## Usage

1. First, make sure you install the campfire-bot gem.
2. `gem install campfire-bot-absentee-camper`
3. Create Gemfile with the following lines:
    gem 'campfire-bot'
    gem 'campfire-bot-absentee-camper'
4. Create your _absentee-camper-config.yml_ file (see below).
5. Register the plugin to your main _config.yml_ file
6. `bundle exec bot <environment>`, where `<environment>` is the
   matching environment from the config file.

## Configuration

Here is a sample config file:

    ---
    production:
      pony_options:
        # NOTE: The colons before these options are very important.
        #       Pony requires that the keys be symbols and not strings.
        #
        :from: Absentee Camper <no-reply@your-company.com>
        :subject: "[Campfire] People are talking about you!"
        :via: :smtp
        :via_options:
          :address: smtp.sendgrid.net
          :port: 587
          :enable_starttls_auto: true
          :authentication: plain
          :user_name: your-user-name
          :password: secret
      users:
        # User with custom (and possibly multiple) notifiers
        chad:
          id: 1234567
          notification_methods:
            Prowl: your-prowl-api-key
        # Default email notifier
        john: 987654

* `production` - This is the environment for which the settins apply.
  You can specify multiple environments (e.g. development, test, etc).
* `pony_options` - The configuration options for [Pony](https://github.com/adamwiggins/pony)
* `users` - Each user line consists of the name of the mention name and
  that user's corresponding 37Signals Campfire user ID.  One way to get
  this user ID is to log into Campfire as a user that has admin privileges,
  click on the _Users_ tab, and then hover over the _change_ link of the
  user for which you want to find the user ID and take note of the number
  in the path (e.g. https://_your-company_.campfirenow.com/member/12345/permissions).
  For example, if you have a user named John Smith with a
  user ID of 12345, and you want to be able to mention them as _@john_,
  the users line in the config file would be `john: 12345`.
* `notification_methods` - Alternate notification methods.  Currently,
  the only notification method other than the default (email) is Prowl.

## TODO

* More specs!
* Provide context in the notification.  For example, in a Campfire
  session there are two users: John and Steve.  Another user, Chad
  is not present in the room:

        John Smith: Hey Steve.  I am having a problem with the build.
        Steve Stallion: Hey John.  I don't know anything about that.  You
        should ask @chad.  That's his department.
        John Smith: Oh, I thought you were the one that handled that.  OK,
        I will wait for Chad's response.

  Currently, the email notification that Absentee Camper sends out will
  only contain the second message, which doesn't have any context about
  what was being discussed.  It would be nice to set some configuration
  variables that indicated you wanted to include context in the
  notification message, and how many lines on either side to include.

## Testing

You have two options:

* run `bundle exec rake`
* run `bundle exec guard` for continuous feedback

## Contributing

Do the usual fork -> change -> pull request dance.
