require 'json'
require 'faraday'

module Rdio
  module Helper
    class Client < Faraday::Connection
      autoload :ActivityStreamType, 'rdio/helper/client/activity_stream_type'

      def initialize(access_token: nil)
        @access_token = access_token
        super('https://services.rdio.com')
        basic_auth(ENV['RDIO_CLIENT_ID'], ENV['RDIO_CLIENT_SECRET'])
      end

      def fetch_authorization_endpoint(redirect_uri)
        response = get('oauth2/authorize?redirect_uri=%s&response_type=code&client_id=%s' % [ redirect_uri, ENV['RDIO_CLIENT_ID'] ])
        response['Location']
      end

      def fetch_access_token(code, redirect_uri)
        response = post('oauth2/token', grant_type: :authorization_code, code: code, redirect_uri: redirect_uri)
        json = JSON.parse(response.body)
        json['access_token']
      end

      def get_favorites
        execute_api_method(:getFavorites)
      end

      def get_current_user
        execute_api_method(:currentUser)
      end

      def get_activity_stream(types: nil, user: raise, scope: 'user', last_id: nil, count: 30)
        data = {}
        data[:types] = types if types
        data[:last_id] = last_id if last_id
        data[:scope] = scope
        data[:user] = user
        data[:count] = count
        execute_api_method(:getActivityStream, data)
      end

      def execute_api_method(method_name, **additional_data)
        data = { method: method_name, access_token: @access_token }.merge(additional_data)
        response = post('api/1', data)
        print "POST api/1 #{method_name}\n"
        print "#{JSON.dump(data)}\n"
        print "#{response.body}\n"
        json = JSON.parse(response.body)
        json['result']
      end
    end
  end
end
