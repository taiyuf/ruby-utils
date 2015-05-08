require 'yaml'
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

    LOG_PREFIX = 'Utils::Configuration'

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
        common = read_yaml 'config/config_common.yml'
        secret = read_yaml 'config/config_secret.yml'
        env    = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'

        if secret
          if secret.has_key?(env.to_sym)
            @@_config = common.merge(secret[env.to_sym])
          else
            Logger.new(STDOUT).warn "#{LOG_PREFIX} could not find RAILS_ENV key: #{env.to_sym} "
            @@_config = common
          end

        else
          @@_config = common
        end

        @@_config
      end

      begin

        if @@_config.nil?
          _init.call
        else
          @@_config
        end

      rescue
        _init.call
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
        File.exist? configfile
      rescue
        log.warn "File does not exist!: #{configfile}"
        return false
      end

      begin
        yaml = YAML.load_file configfile
      rescue Exception => e
        log.warn "#{LOG_PREFIX}.read_yaml, [#{e.class}]: #{e.message}"
        return false
      end

      symbolize yaml
    end

    private

    def symbolize(hash)
      begin
        require 'active_support'
      rescue LoadError

        begin
          require 'hashie'
        rescue LoadError
          raise "#{LOG_PREFIX}: active_support or hashie are required!"
        else
          Hashie.symbolize_keys! hash
        end

      else
        hash.deep_symbolize_keys!
      end
    end

    module_function :get_config, :read_yaml, :init_config
  end

end
