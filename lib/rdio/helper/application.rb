require 'sinatra/base'
require 'pry'

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
          p session[:access_token]
          current_user = client.get_current_user
          group_activity_stream_by_week = GroupActivityStreamByWeek.call(client: client, user_key: current_user['key'])
          @updates_by_week = group_activity_stream_by_week.updates_by_week
          erb :activity
        else
          redirect to('/oauth/redirect')
        end
      end

      post '/playlists' do
        playlist = params[:playlist]

        playlist_attributes = {
          name: playlist[:name],
          description: 'A playlist of favorites added this week',
          tracks: playlist[:tracks]
        }

        response = client.execute_api_method(:createPlaylist, **playlist_attributes)
        FileCache.new('playlists').clear!
        redirect to('/')
      end

      enable :sessions

      helpers do
        def client
          @client ||= Client.new(access_token: session[:access_token])
        end

        def playlists
          @playlists = cache(:playlists){client.execute_api_method(:getPlaylists)['owned']}
        end

        def playlist_exists?(playlist_name)
          playlists.any? { |playlist| playlist['name'] == playlist_name }
        end

        def favorites_includes_track?(track_id)
          favorited_track_keys.include?(track_id)
        end

        def favorited_track_keys
          @favorited_track_keys ||= cache('favorited_track_keys'){client.send(:execute_api_method, :getKeysInFavorites)['keys']}
        end

        def cache(cache_name, &block)
          FileCache.new(cache_name).cache(&block)
        end
      end
    end
  end
end
