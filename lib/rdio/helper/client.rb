require 'json'
require 'faraday'

module Rdio
  module Helper
    class Client < Faraday::Connection
      def initialize
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
    end
  end
end