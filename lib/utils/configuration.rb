require 'yaml'
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

    @@_config = nil

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

      if @@_config.nil?
        common    = read_yaml('config/config_common.yml')
        secret    = read_yaml('config/config_secret.yml')
        s = secret["#{ENV['RAILS_ENV']}"]
        @@_config = s ? common.merge(s) : common
      end

      @@_config
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
      configfile = File.expand_path(file)

      begin
        File.exist?(configfile)
      rescue
        Rails.logger.debug("File does not exist!: #{configfile}")
        raise Exceptions::NotFound
      end

      begin
        yaml = YAML.load_file(configfile)
      rescue Exception => e
        raise "Util::Configuration.read_yaml, [#{e.class}]: #{e.message}"
      end

      yaml
    end

  end

  module_function :init_config, :read_yaml, :get_config
end
