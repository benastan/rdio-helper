require 'bundler'
Bundler.require
require 'dotenv'
Dotenv.load
require 'rdio/helper'
run Rdio::Helper::Application