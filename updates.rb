#!/usr/bin/env ruby
#

require 'rubygems'
# Used for Configuration
require 'yaml'
# https://github.com/piotrmurach/tty-prompt
require 'tty-prompt'
# Colors (https://github.com/piotrmurach/pastel#3-supported-colors)
require 'pastel'

$maxChars = 80
$taskPrefix = '➽  '
$lineCharTitle = '-'
$lineCharCmds = '.'

# Run commands
def runCommand(command)
    pid2 = spawn(command)
    Process.wait pid2
end

# Build the selection list
def update(yamlConf, result)
    line   = $pastel.white($lineCharTitle * $maxChars)
    updateSelection = yamlConf[result]
    showCommands = updateSelection['show_commands']
    runCommands = updateSelection['run_commands']
    puts line, $pastel.yellow.bold(updateSelection['status_message']), line
    updateSelection['commands'].each do |item|
        if showCommands
            puts taskTitle(item)
            puts
        end
        runCommand(item) if runCommands
    end
end

# Style the command title and return it
def taskTitle(item)
    numChars = $maxChars - item.size - $taskPrefix.size - 2
    computedLine = ($lineCharCmds * numChars)
    $pastel.yellow($taskPrefix) + $pastel.bold(item) + "  " + $pastel.yellow.dim(computedLine)
end

# Main program
begin
    # Init Pastel
    $pastel = Pastel.new

    # Init TTY-Prompt
    prompt = TTY::Prompt.new(interrupt: :signal)

    # Get YAML Config
    yamlConf = YAML.load_file(File.join(File.dirname(__FILE__), 'updates.yml'))
    yamlConfCount = yamlConf.size

    # Create TTY-Prompt
    result = prompt.select('Select an update task: ', help: '', active_color: :yellow, per_page: yamlConfCount) do |menu|
        yamlConf.each do |key, value|
            menu.choice value['human_name'], key
        end
    end

    # Run the joint
    update(yamlConf, result)

# Intercept key interruption
rescue Interrupt
    puts
    puts
    puts $pastel.bold('Exiting...')
end
