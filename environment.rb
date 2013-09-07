require 'rubygems'
require 'bundler/setup'

require 'haml'
require 'ostruct'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title => 'SoundMeet',
                 :author => 'Amrit Ayalur',
                 :url_base => 'http://localhost:4567/'
               )


end
