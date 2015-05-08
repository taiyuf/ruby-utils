# -*- coding: utf-8 -*-
#
#== Usage
#
# require 'utils/http_client'
#
# req = HttpClient.get({ url: 'http://example.com/index.html' })
#
# return the Net::HTTP::* object.
#
#== method
#
# HttpClient.get
# HttpClient.post
# HttpClient.put
# HttpClient.delete
#
#== Auguments
#
# set the hash. keys are: 
#
# * url (required):      String object.
# * headers (option):    Hash object of the headers.
# * basic_auth (option): Hash object of the basic authentication infomation. user_name and password keys are required.
#
require 'rack'
require File.expand_path('../configuration', __FILE__)
include Utils::Configuration

module HttpClient

  LOG_PREFIX  = '*** HttpClient:'
  CONF        = get_config[:job_server]
  @basic_auth = nil

  #===
  #
  # @param:  Hash
  # @return: Net::HTTPResponse
  #
  # @example
  #
  # req = HttpClient.get({ url: URL_STRING, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH})
  #
  def get(hash)
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
  # req = HttpClient.post({ url: URL_STRING, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH})
  #
  def post(hash)
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
  # req = HttpClient.put({ url: URL_STRING, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH})
  #
  def put(hash)
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
  # req = HttpClient.delete({ url: URL_STRING, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH})
  #
  def delete(hash)
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
    raise "#{LOG_PREFIX} params property is required!" unless hash.has_key? :params
    raise "#{LOG_PREFIX} params should be Hash!"       unless hash[:params].class.to_s == 'Hash'

    raise "#{LOG_PREFIX} url property is required!"    unless hash.has_key? :url

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
      url = "#{uri[:path]}?#{Rack::Utils.build_query(params)}"
      req = Net::HTTP::Get.new url
    elsif type.to_s == 'post'
      req = Net::HTTP::Post.new   uri[:path]
      req.set_form_data params if params
    elsif type.to_s == 'put'
      req = Net::HTTP::Put.new    uri[:path]
      req.set_form_data params if params
    elsif type.to_s == 'delete'
      url = "#{uri[:path]}?#{Rack::Utils.build_query(params)}"
      req = Net::HTTP::Delete.new url
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
