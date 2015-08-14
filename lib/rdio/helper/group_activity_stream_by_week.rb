module Rdio
  module Helper
    class GroupActivityStreamByWeek
      include Interactor

      def call
        client = context[:client]
        user_key = context[:user_key]

        file_cache = FileCache.new(:activity_stream_cache)

        updates = file_cache.cache do
          last_id = nil
          updates = []
          while last_id != 0
            activity_stream = client.get_activity_stream(
              user: user_key,
              last_id: last_id,
              types: [ Client::ActivityStreamType::USER_FAVORITED_AN_ITEM ]
            )
            last_id = activity_stream['last_id']
            updates = updates.concat(activity_stream['updates'])
          end
          updates
        end

        updates_by_week = updates.inject({}) do |memo, update|
          date = DateTime.parse(update['date'])
          week_number = date.strftime('%Y%W').to_i
          memo[week_number] ||= []
          memo[week_number] << update
          memo
        end

        context[:updates_by_week] = updates_by_week
      end
    end
  end
end
