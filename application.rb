require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'soundcloud'
require 'oauth2'
require 'uri'
require 'json'
require 'better_errors'
require 'rMeetup'
require 'geocoder'
require 'httparty'
require 'awesome_print'
require File.join(File.dirname(__FILE__), 'environment')

class MeetupParty
	include HTTParty
	format :json
end


enable :sessions
before do 
	RMeetup::Client.api_key = '5336243622357f5d3153263216a444b'
end


configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path("..", __FILE__)
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
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

	genres = []

	tracks.each do |t|
		genres << t.genre
	end
	topic_ids = []
	topics = RMeetup::Client.fetch(:topics, {:search => genres.join(' '), :page => 10})
	topics.each do |t|
		topic_ids << t.urlkey
	end

	#@meetup_response = HTTParty.get('https://api.meetup.com/2/concierge?lon=#{@@long}&lat=#{@@lat}&daily_target=10&topic_id="#{topic_ids}')

	




	#@events = RMeetup::Client.fetch(:open_events, {:city => city, :state => state, :country => country, :daily_target => 5, :topic => topic_ids })

	#@events = RMeetup::Client.fetch(:events, {:topic => topic_ids })
  @lat = session[:lat]
  @long = session[:long]
  @topics = topic_ids

  @meetup_response = MeetupParty.get("https://api.meetup.com/2/open_events.json?category=21&radius=50&lon=#{@long}&lat=#{@lat}&topic=#{topic_ids.join(',')}&key=5336243622357f5d3153263216a444b")
 
	haml :root

end

get '/soundcloud' do
	client = Soundcloud.new(:client_id => '1e4be0491349b3dce6001760431265eb',
													:client_secret => 'd5b42e696073e24b5a4e8fe6f2aa4af8',
													:redirect_uri => "http://localhost:9393/callback")
	redirect client.authorize_url()
end

post '/coords' do
	session[:lat] = params[:lat]
	session[:long] = params[:long]
end
