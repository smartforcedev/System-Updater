# The Dummy class is responsible for ...
class SystemUpdates
  # constants


  # mutable data
  # attr_accessor :max_chars, :taskprefix, :linechartitle, :linecharcmds

  # constructor and initialization of mutable data
  # (if it has default values, that is)
  def initialize
    @max_chars = 80
    @taskprefix = '➽  '.freeze
    @linechartitle = '-'.freeze
    @linecharcmds = '.'.freeze
  end

  # Run commands
  def run_command(command)
    pid = spawn(command)
    Process.wait pid
  end

  # check if our config is a valid file
  def check_config_exists(yaml_file)
    if File.exist?(yaml_file)
      return true
    else
      puts
      puts $pastel.white('The file: ') + $pastel.bold(yaml_file) + $pastel.white(' does not exist.')
      puts
      puts $pastel.red('Please check your config file') + "\n"
      exit
    end
  end

  # load config
  def load_config(yaml_file)
      conf = YAML.load_file(yaml_file)
      return conf
  end

  # Build the selection list
  def update(yaml_conf, result)
    line = $pastel.white(@linechartitle * @max_chars)
    update_selection = yaml_conf[result]
    show_commands = update_selection['show_commands']
    run_commands = update_selection['run_commands']
    puts line, $pastel.yellow.bold(update_selection['status_message']), line
    update_selection['commands'].each do |item|
      if show_commands
        puts task_title(item)
        puts
      end
      run_command(item) if run_commands
    end
  end

  # Style the command title and return it
  def task_title(item)
    num_chars = @max_chars - item.size - @taskprefix.size - 2
    computed_line = (@linecharcmds * num_chars)
    $pastel.yellow(@taskprefix) + $pastel.bold(item) + "  " + $pastel.yellow.dim(computed_line)
  end

  # Main program
  def run
    begin
      # Init Pastel
      $pastel = Pastel.new

      # Init TTY-Prompt
      prompt = TTY::Prompt.new(interrupt: :signal)

      # Get global Config
      if check_config_exists(File.join(File.dirname(__FILE__), 'config.yml'))
        global_conf = load_config(File.join(File.dirname(__FILE__), 'config.yml'))
        command_file_path = File.expand_path(File.join('~/', global_conf['settings']['command_file']))
      end

      # Get YAML Config
      if check_config_exists(command_file_path)
        yaml_conf = load_config(command_file_path)
        yaml_conf_count = yaml_conf['tools'].size
      end

      # Show command file Path
      if global_conf['settings']['show_command_file_path']
        puts $pastel.bold('Command File Path: ') + $pastel.blue(command_file_path) + "\n"
      end

      # Show Script Path
      if global_conf['settings']['show_configuration_path']
        puts $pastel.bold('Configuration Path: ') + $pastel.blue(File.join(File.dirname(__FILE__), 'config.yml')) + "\n"
      end

      # Add Spacer
      if global_conf['settings']['show_configuration_path'] || global_conf['settings']['show_command_file_path']
        puts "\n"
      end

      # Create TTY-Prompt
      result = prompt.select('Select an update task: ', help: '', active_color: :yellow, per_page: yaml_conf_count) do |menu|
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
