# -*- coding: utf-8 -*-
#
#== Usage
#
# require 'utils/http_client'
# include Utils::HttpClient
#
# req = GET { url: 'http://example.com/index.html' }
#
# return the Net::HTTP::* object.
#
#== method
#
# Utils::HttpClient.GET
# Utils::HttpClient.POST
# Utils::HttpClient.PUT
# Utils::HttpClient.DELETE
#
#== Auguments
#
# set the hash. keys are: 
#
# * url (required):      String object.
# * params (option):     Hash object of the parameters.
# * headers (option):    Hash object of the headers.
# * basic_auth (option): Hash object of the basic authentication infomation. user_name and password keys are required.
#
require 'rack'
require File.expand_path('../configuration', __FILE__)
include Utils::Configuration

module Utils

  module HttpClient

    LOG_PREFIX  = '*** Utils::HttpClient:'

    #===
    #
    # @param:  Hash
    # @return: Net::HTTPResponse
    #
    # @example
    #
    # res = GET url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH
    # puts res.body
    #
    def GET(hash)
      check_arguments(hash)
      uri = parse_uri hash[:url]
      req = make_request 'get', uri, hash[:params], hash[:headers], hash[:basic_auth]
      Net::HTTP.new(uri[:host], uri[:port]).start do |http| http.request req end
    end

    #===
    #
    # @param:  Hash
    # @return: Net::HTTPResponse
    #
    # @example
    #
    # res = POST url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH
    # puts res.body
    #
    def POST(hash)
      check_arguments(hash)
      uri = parse_uri hash[:url]
      req = make_request 'post', uri, hash[:params], hash[:headers], hash[:basic_auth]
      Net::HTTP.new(uri[:host], uri[:port]).start do |http| http.request req end
    end

    #===
    #
    # @param:  Hash
    # @return: Net::HTTPResponse
    #
    # @example
    #
    # res = PUT url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH}
    # puts res.body
    #
    def PUT(hash)
      check_arguments(hash)
      uri = parse_uri hash[:url]
      req = make_request 'put', uri, hash[:params], hash[:headers], hash[:basic_auth]
      Net::HTTP.new(uri[:host], uri[:port]).start do |http| http.request req end
    end

    #===
    #
    # @param:  Hash
    # @return: Net::HTTPResponse
    #
    # @example
    #
    # res = DELETE url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH
    # puts res.body
    #
    def DELETE(hash)
      check_arguments(hash)
      uri = parse_uri hash[:url]
      req = make_request 'delete', uri, hash[:params], hash[:headers], hash[:basic_auth]
      Net::HTTP.new(uri[:host], uri[:port]).start do |http| http.request req end
    end

    private

    #===
    #
    # @param  Hash
    # @return true
    #
    # 引数のHashの内容をチェックし、問題がなければ true を、問題があれば raise する
    #
    def check_arguments(hash)
      if hash.has_key? :params
        raise "#{LOG_PREFIX} params should be Hash!" unless hash[:params].class.to_s == 'Hash'
      end

      raise "#{LOG_PREFIX} url property is required!" unless hash.has_key? :url

      if hash.has_key? :basic_auth
        raise "#{LOG_PREFIX} basic_auth property should have the keys user_name and password." unless hash[:basic_auth].has_key? :user_name and hash[:basic_auth].has_key? :password
      end

      true
    end

    #===
    #
    # @param  String
    # @return nil
    #
    # URIの文字列を受け取って、host, port, pathのプロパティを設定する
    #
    # @example
    #
    # parse_uri('http://localhost/hoge/') #=> self.scheme = 'http'
    #                                              self.host   = 'localhost'
    #                                              self.port   = 80
    #                                              self.path   = '/hoge'
    #
    def parse_uri(url)
      url = URI.parse(url)
      uri = {}
      uri[:scheme] = url.scheme
      uri[:host]   = url.host
      uri[:port]   = url.port

      if url.path =~ /(.*)\/$/
        uri[:path] = url.path.sub(/\/$/, '')
        uri[:url]  = url.to_s.sub(/\/$/, '')
      else
        uri[:path] = url.path
        uri[:url]  = url.to_s
      end

      uri
    end

    #===
    #
    # @param  String, String, String, String
    # @return Net::HTTPRequest
    #
    # @example
    #
    # req = make_request('get',                                 # => get, post, put, delete
    #                    'http://localhost/foo/bar',            # => URL
    #                    { foo: 'bar' }                         # => parameters
    #                    { HTTP_API_KEY: 'hoge' },              # => hash of headers
    #                    { user_name: 'foo', password: 'bar' }) # => infomation of the  basic authentication account.
    #
    def make_request(type, uri, params=nil, headers=nil, basic_auth=nil)

      if type.to_s == 'get'
        url = params.nil? ?
          "#{uri[:url]}" :
          "#{uri[:url]}?#{Rack::Utils.build_query(params)}"
        req = Net::HTTP::Get.new URI(url)
      elsif type.to_s == 'post'
        req = Net::HTTP::Post.new   uri[:url]
        req.set_form_data params if params
      elsif type.to_s == 'put'
        req = Net::HTTP::Put.new    uri[:url]
        req.set_form_data params if params
      elsif type.to_s == 'delete'
        url = params.nil? ?
          "#{uri[:url]}" :
          "#{uri[:url]}?#{Rack::Utils.build_query(params)}"
        req = Net::HTTP::Delete.new URI(url)
      else
        raise "Unknown type: #{type}."
      end
      # API認証
      if headers
        headers.each do |k, v|
          req[k] = v
        end
      end

      # Basic認証
      if basic_auth
        req.basic_auth basic_auth[:user_name], basic_auth[:password]
      end

      req
    end

  end

end
