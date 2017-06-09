#!/usr/bin/env ruby
#

require 'rubygems'
# Used for Configuration
require 'yaml'
# https://github.com/piotrmurach/tty-prompt
require 'tty-prompt'
# Colors (https://github.com/piotrmurach/pastel#3-supported-colors)
require 'pastel'

 # Public: Various methods useful for performing mathematical operations.
# All methods are module methods and should be called on the Math module.
#
# Examples
#
#   Math.square_root(9)
#   # => 3
# variables and methods start lowercase
class SystemUpdates
  # constants
  TASKPREFIX = '➽  '.freeze
  LINECHARTITLE = '-'.freeze
  LINECHARCMDS = '.'.freeze

  # mutable data
  attr_accessor :max_chars


  # constructor and initialization of mutable data
  # (if it has default values, that is)
  def initialize
    self.max_chars = 80
  end

  # Run commands
  def run_command(command)
    pid2 = spawn(command)
    Process.wait pid2
  end

  # Build the selection list
  def update(yaml_conf, result)
    line = $pastel.white(LINECHARTITLE * max_chars)
    update_selection = yaml_conf[result]
    showCommands = update_selection['show_commands']
    runCommands = update_selection['run_commands']
    puts line, $pastel.yellow.bold(update_selection['status_message']), line
    update_selection['commands'].each do |item|
      if showCommands
        puts taskTitle(item)
        puts
      end
      run_command(item) if runCommands
    end
  end

  # Style the command title and return it
  def taskTitle(item)
    numChars = max_chars - item.size - TASKPREFIX.size - 2
    computedLine = (LINECHARCMDS * numChars)
    $pastel.yellow(TASKPREFIX) + $pastel.bold(item) + "  " + $pastel.yellow.dim(computedLine)
  end

  # Main program
  def run
    begin
      # Init Pastel
      $pastel = Pastel.new

      # Init TTY-Prompt
      prompt = TTY::Prompt.new(interrupt: :signal)

      # Get YAML Config
      yaml_conf = YAML.load_file(File.join(File.dirname(__FILE__), 'system_updates.yml'))
      yaml_confCount = yaml_conf['tools'].size

      # Show Script Path
      if yaml_conf['settings']['show_script_path']
        puts $pastel.bold('Script Path: ') + $pastel.blue(File.dirname(__FILE__)) + "\n\n"
      end

      # Create TTY-Prompt
      result = prompt.select('Select an update task: ', help: '', active_color: :yellow, per_page: yaml_confCount) do |menu|
        yaml_conf['tools'].each do |key, value|
          menu.choice value['human_name'], key
        end
      end

      # Run the joint
      update(yaml_conf['tools'], result)
    end

  # Intercept key interruption
  rescue Interrupt
    puts
    puts
    puts $pastel.bold('Exiting...')
  end
end

# finally, run the damn thing!
SystemUpdates.new.run
