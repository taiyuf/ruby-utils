require 'spec_helper'
require 'yaml'
require File.expand_path('../../../lib/utils/configuration', __FILE__)
include Utils::Configuration

RSpec.describe Utils::Configuration do

  context '.get_config' do

    it 'read common yaml.' do
      get_config
      get_config
      get_config
      expect(get_config[:common_name]).to eq('hoge')
    end

    it 'read secret yaml with develoment env.' do
      ENV['RAILS_ENV'] = 'development'
      Utils::Configuration.init_config
      expect(get_config[:secret_name]).to eq('foo')
    end

    it 'read common yaml with test env.' do
      ENV['RAILS_ENV'] = 'test'
      Utils::Configuration.init_config
      expect(get_config[:secret_name]).to eq('bar')
    end

  end

end
