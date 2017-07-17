#!/usr/bin/env ruby
#

require 'rubygems'
# Used for Configuration
require 'yaml'
# https://github.com/piotrmurach/tty-prompt
require 'tty-prompt'
# Colors (https://github.com/piotrmurach/pastel#3-supported-colors)
require 'pastel'

# Load our class
require './system_updates.class.rb'

# finally, run the damn thing!
SystemUpdates.new.run
