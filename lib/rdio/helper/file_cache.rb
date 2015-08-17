module Rdio
  module Helper
    class FileCache
      attr_reader :storage, :max_age, :cache_name

      def initialize(cache_name, max_age: nil)
        @cache_name = cache_name
        @storage = Pathname('./cache/%s.json' % cache_name)
        @max_age = max_age
      end

      def cache
        if valid?
          JSON.parse(storage.read)
        else
          print "Cache #{cache_name} is invalid.\n"
          yield.tap { |data| write(data) }
        end
      end

      def write(contents)
        storage.write(JSON.dump(contents))
      end

      def clear!
        storage.delete
      end

      def age
        Time.new - storage.mtime
      end

      def valid?
        storage.file? && (max_age.nil? || age <= max_age)
      end
    end
  end
end
