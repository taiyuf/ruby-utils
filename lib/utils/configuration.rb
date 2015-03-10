require 'yaml'
require 'hashie'
require 'logger'
#
#=utils/configuration.rb
#
#== Usage
#
# require 'utils/configuration'
# include Utils::Configuration
#
# @config = get_config
#
# Return the hash from yaml file (config/config_common.yml, config/config_secret.yml).
#
#=== config/config_common.yml
#
# Please set the not secure value in this file.
#
#=== config/config_secret.yml
#
# Please set the secure value with RAILS_ENV and add this file to .gitignore.
# return the hash which RAILS_ENV's value.
#
# ex) sample config_secret.yml
#
# return { mysql: { user_name: hoge, password: hoge } }, if RAILS_ENV == 'production'
#
# ----------------------
# production:
#   mysql:
#     user_name: hoge
#     password: hoge
#
# development:
#   mysql:
#     user_name: foo
#     password: foo
#
# test:
#   mysql:
#     user_name: bar
#     password: bar
# ----------------------
#
#
module Utils

  module Configuration

    #===
    #
    # @param   nil
    # @return  Hash
    # @require config/config_common.yml and config/config_secret.yml
    #
    # @example
    #
    # config = get_config
    # hoge   = config['hoge']
    #
    def get_config

      _init = Proc.new do
        common = read_yaml('config/config_common.yml')
        secret = read_yaml('config/config_secret.yml')
        env    = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
        if secret
          @@_config = secret.has_key?(env) ? common.merge(secret[env]) : common
        else
          @@_config = common
        end

        @@_config = Hashie.symbolize_keys! @@_config
      end

      begin

        if @@_config.nil?
          _init.call
        else
          @@_config
        end

      rescue
        _init.call
        @@_config
      end

    end

    def init_config
      @@_config = nil
      get_config
    end

    #===
    #
    # @param  String
    # @return Hash
    #
    # @example
    #
    # hash = read_yaml('path/to/yaml')
    # hoge = hash['hoge']
    #
    def read_yaml(file)
      log        = Logger.new(STDOUT)
      configfile = File.expand_path(file)

      begin
        File.exist?(configfile)
      rescue
        log.error("File does not exist!: #{configfile}")
        return false
      end

      begin
        yaml = YAML.load_file(configfile)
      rescue Exception => e
        log.error("Util::Configuration.read_yaml, [#{e.class}]: #{e.message}")
        return false
      end

      yaml
    end

    module_function :get_config, :read_yaml, :init_config
  end

end
