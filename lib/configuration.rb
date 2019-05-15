require 'mongoid'
require 'dotenv'
require_relative 'ext'

class Configuration
  include Singleton

  @configured = false

  def configure_for_env(env = 'development')
    if @configured
      puts "Already configured for env #{@env}. Do nothing;"
      return
    end
    @env = env
    @errors = []

    @app_root = File.expand_path '../', __dir__

    try_from_dotenv

    check_vars 'APP_SECRET'
    configure_database
    if env == 'development'
      printConfig
    end
    @configured = true
  end

  attr_reader :scripts_attachments_root,
              :posts_attachments_root,
              :resources_root

  attr_reader :app_root

  private

  def try_from_dotenv
    Dotenv.load(".env.#{@env}.local", ".env.#{@env}", ".env")
  end

  def configure_database
    done = false
    if @env === 'development'
      cfg_path = File.expand_path 'mongoid.yml', app_root
      if File.exists? cfg_path
        Mongoid.load!(cfg_path, :development)
        done = true
      end
    end
    unless done
      configure_from_env
    end
  end

  def check_vars(*vars)
    vars.each(&method(:check_var))
    raise MissedEnvironmentVariable.new(@errors.join(',')) if @errors.length > 0
  end

  def check_var(name)
    @errors << name if ENV[name].blank?
  end

  def configure_from_env
    check_vars 'DB_HOST', 'DB_DATABASE', 'DB_USERNAME', 'DB_PASSWORD'
    Mongoid.configure do |config|
      config.clients.default = {
        hosts: [ENV['DB_HOST']],
        database: ENV['DB_DATABASE'],
        options: {
          user: ENV['DB_USERNAME'],
          password: ENV['DB_PASSWORD']
        }
      }
      config.log_level = :warn
    end
  end

  def printConfig
    puts Mongoid.default_client.options[:user]
    puts Mongoid.default_client.options[:password]
    puts Mongoid.default_client.options[:database]
    puts Mongoid.default_client.cluster.servers[0].address
    puts self.app_root
    puts self.posts_attachments_root
    puts self.scripts_attachments_root
    puts @env
  end

end

class MissedEnvironmentVariable < StandardError
  def initialize(var_name)
    super("Missed required variable(s): #{var_name}")
  end
end