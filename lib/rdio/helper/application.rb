require 'sinatra/base'

module Rdio
  module Helper
    class Application < Sinatra::Base
      get '/oauth/redirect' do
        client = Client.new
        authorization_endpoint = client.fetch_authorization_endpoint(to('/oauth/callback'))
        redirect to(authorization_endpoint)
      end

      get '/oauth/callback' do
        client = Client.new
        access_token = client.fetch_access_token(params[:code], to('/oauth/callback'))
        session[:access_token] = access_token
        redirect to('/')
      end

      get '/' do
        if session[:access_token]
          erb 'Greate!'
        else
          redirect to('/oauth/redirect')
        end
      end

      enable :sessions
    end
  end
end
