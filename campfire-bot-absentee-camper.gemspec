# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "campfire_bot/absentee_camper/version"

Gem::Specification.new do |s|
  s.name        = "campfire-bot-absentee-camper"
  s.version     = CampfireBot::AbsenteeCamper::VERSION
  s.authors     = ["hoverlover"]
  s.email       = ["hoverlover@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Plugin for campfire-bot that monitors incoming messages and notifies a user that is @mentioned if they aren't present.}
  s.description = s.summary

  s.rubyforge_project = "campfire-bot-absentee-camper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'campfire-bot', '~> 0.1.0'
  s.add_dependency 'pony', '~> 1.3'
  s.add_dependency 'prowl', '~> 0.1.3'
end
