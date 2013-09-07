require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'soundcloud'
require 'oauth2'
require 'uri'
require 'json'
require 'better_errors'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path("..", __FILE__)
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"

  RMeetup::Client.api_key = '5336243622357f5d3153263216a444b'
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

# root page
get '/' do	

	if defined? @@token
		
 		client = Soundcloud.new(:access_token => @@token)

 		current_user = client.get('/me')
 		@username = current_user.username

 		@tracks = client.get('/me/favorites')

 	end

  haml :root
end

get '/callback' do
	client = Soundcloud.new(:client_id => '1e4be0491349b3dce6001760431265eb',
													:client_secret => 'd5b42e696073e24b5a4e8fe6f2aa4af8',
													:redirect_uri => "http://localhost:9393/callback")

# exchange authorization code for access token
	code = params[:code]
	access_token = client.exchange_token(:code => code)
	@@token = access_token.access_token

	client = Soundcloud.new(:access_token => @@token)

	#current_user = client.get('/me')
	@username = client.get('/me').username

	tracks = client.get('/me/favorites')

	@genres = []

	tracks.each do |t|
		@genres << t.genre
	end

	haml :root

end

get '/soundcloud' do
	client = Soundcloud.new(:client_id => '1e4be0491349b3dce6001760431265eb',
													:client_secret => 'd5b42e696073e24b5a4e8fe6f2aa4af8',
													:redirect_uri => "http://localhost:9393/callback")
	redirect client.authorize_url()
end

