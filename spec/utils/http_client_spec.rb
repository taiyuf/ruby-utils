require 'spec_helper'
require 'rack'
require 'webmock/rspec'
require File.expand_path('../../../lib/utils/http_client', __FILE__)
include HttpClient

# RSpec.shared_examples 'response should be OK.' do |res|

#   it 'should be kind of Net::HTTPOK.' do
#     expect(res).to be_kind_of Net::HTTPOK
#   end

#   it 'should be valid request.' do
#     expect(res.body).to eq 'OK'
#   end
# end

RSpec.describe HttpClient do

  describe 'private method: ' do

    describe '.check_arguments' do
      context 'fail' do
        it 'no params' do
          expect{HttpClient.send('check_arguments', { foo: 1 })}.to raise_error RuntimeError, '*** HttpClient: params property is required!'
        end

        it 'not hash' do
          expect{HttpClient.send('check_arguments', { params: 1 })}.to raise_error RuntimeError, '*** HttpClient: params should be Hash!'
        end

        it 'should have basic_auth[:user_name]' do
          expect{HttpClient.send('check_arguments', { params: { foo: 1 }, url: 'hoge', basic_auth: { password: 1} } )}.to raise_error RuntimeError, '*** HttpClient: basic_auth property should have the keys user_name and password.'
        end

        it 'should have basic_auth[:password]' do
          expect{HttpClient.send('check_arguments', { params: { foo: 1 }, url: 'hoge', basic_auth: { user_name: 1} } )}.to raise_error RuntimeError, '*** HttpClient: basic_auth property should have the keys user_name and password.'
        end

        it 'no url' do
          expect{HttpClient.send('check_arguments', { params: { foo: 1 } })}.to raise_error RuntimeError, '*** HttpClient: url property is required!'
        end
      end

      context 'success' do
        it 'has only params and url' do
          expect(HttpClient.send('check_arguments', { params: { foo: 1 }, url: 'hoge' })).to eq true
        end

        it 'has params and basic_auth' do
          expect(HttpClient.send('check_arguments', { params: { foo: 2 }, url: 'hoge', basic_auth: { user_name: 1, password: 2 } } )).to eq true
        end
      end

    end

    describe '.parse_uri' do

      context 'success' do
        before do
          @uri = HttpClient.send('parse_uri', 'http://localhost:8080/foo/bar')
        end

        it 'scheme' do
          expect(@uri[:scheme]).to eq 'http'
        end

        it 'host' do
          expect(@uri[:host]).to eq 'localhost'
        end

        it 'port' do
          expect(@uri[:port]).to eq 8080
        end

        it 'path 1' do
          expect(@uri[:path]).to eq '/foo/bar'
        end

        it 'url 1' do
          expect(@uri[:url]).to eq 'http://localhost:8080/foo/bar'
        end

        it 'path 2' do
          expect(HttpClient.send('parse_uri', 'http://localhost/foo/')[:path]).to eq '/foo'
        end

        it 'url 2' do
          expect(HttpClient.send('parse_uri', 'http://localhost/foo/')[:url]).to eq 'http://localhost/foo'
        end
      end
    end

    describe '.make_request' do

      before do
        @url        = 'http://hoge.com/foo/bar'
        @params     = { foo: 'bar' }
        @query      = Rack::Utils.build_query(@params)
        @headers    = { HTTP_FOO: 'foo' , HTTP_BAR: 'bar' }
        @basic_auth = { user_name: 'foo', password: 'bar' }
      end

      # it 'check basic_auth properties' do
      #   req = HttpClient.get { params: { foo: 1 }, basic_auth: { user_name: 'foo', password: 'bar' }, url: @url }
      # end


      context 'fail' do
        
      end


      context 'success' do

        context '.get' do

          before do
            uri = HttpClient.send('parse_uri', @url)
            url = "#{uri[:scheme]}://#{@basic_auth[:user_name]}:#{@basic_auth[:password]}@#{uri[:host]}:#{uri[:port]}#{uri[:path]}?#{@query}"

            stub_request(:get, url)
              .with(headers: @headers)
              .to_return(body: "OK", status: 200)

            @res = HttpClient.get({ url: @url, params: @params, headers: @headers, basic_auth: @basic_auth})
          end

          it 'should be kind of Net::HTTPOK.' do
            expect(@res).to be_kind_of Net::HTTPOK
          end

          it 'should be valid request.' do
            expect(@res.body).to eq 'OK'
          end

        end

        context '.post' do

          before do
            uri = HttpClient.send('parse_uri', @url)
            url = "#{uri[:scheme]}://#{@basic_auth[:user_name]}:#{@basic_auth[:password]}@#{uri[:host]}:#{uri[:port]}#{uri[:path]}"

            stub_request(:post, url)
              .with(headers: @headers, body: @params)
              .to_return(body: "OK", status: 200)

            @res = HttpClient.post({ url: @url, params: @params, headers: @headers, basic_auth: @basic_auth})
          end

          it 'should be kind of Net::HTTP::OK.' do
            expect(@res).to be_kind_of Net::HTTPOK
          end

          it 'should be valid request.' do
            expect(@res.body).to eq 'OK'
          end

        end

        context '.put' do

          before do
            uri = HttpClient.send('parse_uri', @url)
            url = "#{uri[:scheme]}://#{@basic_auth[:user_name]}:#{@basic_auth[:password]}@#{uri[:host]}:#{uri[:port]}#{uri[:path]}"

            stub_request(:put, url)
              .with(headers: @headers, body: @params)
              .to_return(body: "OK", status: 200)

            @res = HttpClient.put({ url: @url, params: @params, headers: @headers, basic_auth: @basic_auth})
          end

          it 'should be kind of Net::HTTP::OK.' do
            expect(@res).to be_kind_of Net::HTTPOK
          end

          it 'should be valid request.' do
            expect(@res.body).to eq 'OK'
          end

        end

        context '.delete' do

          before do
            uri = HttpClient.send('parse_uri', @url)
            url = "#{uri[:scheme]}://#{@basic_auth[:user_name]}:#{@basic_auth[:password]}@#{uri[:host]}:#{uri[:port]}#{uri[:path]}?#{@query}"

            stub_request(:delete, url)
              .with(headers: @headers)
              .to_return(body: "OK", status: 200)

            @res = HttpClient.delete({ url: @url, params: @params, headers: @headers, basic_auth: @basic_auth})
          end

          it 'should be kind of Net::HTTPOK.' do
            expect(@res).to be_kind_of Net::HTTPOK
          end

          it 'should be valid request.' do
            expect(@res.body).to eq 'OK'
          end

        end

      end
    end
  end
end

