module Rdio
  module Helper
    class FileCache
      attr_reader :storage

      def initialize(cache_name)
        @storage = Pathname('./cache/%s.json' % cache_name)
      end

      def cache
        if storage.file?
          JSON.parse(storage.read)
        else
          yield.tap { |data| write(data) }
        end
      end

      def write(contents)
        storage.write(JSON.dump(contents))
      end

      def clear!
        storage.delete
      end
    end
  end
end
