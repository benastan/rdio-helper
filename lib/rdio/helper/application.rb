require 'sinatra/base'
require 'pry'

module Rdio
  module Helper
    class Application < Sinatra::Base
      before /^\/(?!(oauth))/ do
        unless access_token
          redirect to('/oauth/redirect')
        end
      end

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
        current_user = client.get_current_user
        group_activity_stream_by_week = GroupActivityStreamByWeek.call(client: client, user_key: current_user['key'])
        @updates_by_week = group_activity_stream_by_week.updates_by_week
        erb :activity
      end

      get '/weeks/:week_id' do
        if params[:refresh]
          FileCache.new('playlists').clear!
          redirect to('/weeks/%s' % params[:week_id])
          next
        end

        current_user = client.get_current_user
        group_activity_stream_by_week = GroupActivityStreamByWeek.call(client: client, user_key: current_user['key'])
        @week_number = params[:week_id]
        @updates = group_activity_stream_by_week.updates_by_week[params[:week_id].to_i]
        erb :week
      end

      post '/playlists' do
        playlist = params[:playlist]

        playlist_attributes = {
          name: playlist[:name],
          description: 'A playlist of favorites added this week',
          tracks: playlist[:tracks]
        }

        client.execute_api_method(:deletePlaylist, playlist: playlist[:name]) if playlist_exists?(playlist[:name])
        client.execute_api_method(:createPlaylist, **playlist_attributes)
        FileCache.new('playlists').clear!
        redirect to('/')
      end

      enable :sessions

      helpers do
        def access_token
          ENV['RDIO_ACCESS_TOKEN'] || session[:access_token]
        end

        def client
          @client ||= Client.new(access_token: access_token)
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

        def get_tracks(track_ids, &block)
          digest = Digest::SHA256.new
          digest.update(track_ids.join(','))
          tracks = cache('track_%s' % digest.to_s) { client.execute_api_method(:get, keys: track_ids, extras: [ :playCount, :isInCollection ]) }
          tracks.each(&:block) if block_given?
          tracks
        end

        def tracks
          Track.retrieve_tracks(favorited_track_keys, client: client, batch_size: 250)
        end

        def cache(cache_name, &block)
          FileCache.new(cache_name).cache(&block)
        end
      end
    end
  end
end
