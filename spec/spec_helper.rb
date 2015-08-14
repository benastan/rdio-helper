require 'bundler'
Bundler.require
require 'dotenv'
Dotenv.load
require 'rdio/helper'
require 'rack/test'


def show_response
  File.write('screen.html', favorites.body)
  `open screen.html`
end