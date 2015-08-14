require "rdio/helper/version"
require "interactor"

module Rdio
  module Helper
    autoload :Client, 'rdio/helper/client'
    autoload :Application, 'rdio/helper/application'
    autoload :FileCache, 'rdio/helper/file_cache'
    autoload :GroupActivityStreamByWeek, 'rdio/helper/group_activity_stream_by_week'
  end
end
