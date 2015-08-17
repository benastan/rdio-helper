module Rdio
  module Helper
    class Track
      def self.retrieve_tracks(track_ids, client: raise, batch_size: 100)
        digest = Digest::SHA256.new
        digest.update(track_ids.join(','))
        file_cache = FileCache.new('tracks_%s' % digest.to_s, max_age: 15)
        file_cache.cache do
          tracks = {}
          track_ids.each_slice(batch_size) do |track_ids|
            tracks.merge!(client.execute_api_method(:get, keys: track_ids))
          end
          tracks
        end
      end
    end
  end
end