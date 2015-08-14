module Rdio
  module Helper
    class Client < Faraday::Connection
      module ActivityStreamType
        TRACK_ADDED_TO_COLLECTION = 0
        TRACK_ADDED_TO_PLAYLIST = 1
        FRIEND_ADDED = 3
        USER_JOINED = 5
        COMMENT_ADDED_TO_TRACK = 6
        COMMENT_ADDED_TO_ALBUM = 7
        COMMENT_ADDED_TO_ARTIST = 8
        COMMENT_ADDED_TO_PLAYLIST = 9
        TRACK_ADDED_VIA_MATCH_COLLECTION = 10
        USER_SUBSCRIBED_TO_RDIO = 11
        TRACK_SYNCED_TO_MOBILE = 12
        USER_CREATED_A_PLAYLIST = 13
        USER_REPLIED_TO_A_COMMENT = 39
        USER_FAVORITED_AN_ITEM = 41
        USER_LIKED_A_COMMENT = 42

        MAP = {
          0 => TRACK_ADDED_TO_COLLECTION,
          1 => TRACK_ADDED_TO_PLAYLIST,
          3 => FRIEND_ADDED,
          5 => USER_JOINED,
          6 => COMMENT_ADDED_TO_TRACK,
          7 => COMMENT_ADDED_TO_ALBUM,
          8 => COMMENT_ADDED_TO_ARTIST,
          9 => COMMENT_ADDED_TO_PLAYLIST,
          10 => TRACK_ADDED_VIA_MATCH_COLLECTION,
          11 => USER_SUBSCRIBED_TO_RDIO,
          12 => TRACK_SYNCED_TO_MOBILE,
          13 => USER_CREATED_A_PLAYLIST,
          39 => USER_REPLIED_TO_A_COMMENT,
          41 => USER_FAVORITED_AN_ITEM,
          42 => USER_LIKED_A_COMMENT
        }
      end
    end
  end
end
