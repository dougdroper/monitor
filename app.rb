require 'sinatra'
require 'json'
require 'pusher'
require 'rest-client'
require_relative 'lib/build'

configure do
  require 'redis'
  redisUri = ENV["REDISTOGO_URL"] || 'redis://0.0.0.0:6379'
  uri = URI.parse(redisUri)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

configure do
  TOKEN = ENV["P_TOKEN"]
  PROJECT = ENV["P_PROJECT"]
  P_URL = "https://www.pivotaltracker.com/services/v5"
  PUSH_TOKEN = ENV["PUSH_TOKEN"]
  PUSH_USER = ENV["PUSH_USER"]
end

get '/monitor' do
  @status = build.status
  @number = build.number
  @velocity = build.velocity
  erb :index
end

post '/story_updated' do
  data = JSON.parse(request.env["rack.input"].read)
  build.velocity = build.retrieve_velocity
  build.notify_monitor
  Pusher['test_channel'].trigger('story', {
    :data => data
  })
end

get '/status' do
  content_type :json
  { :data => build.status }.to_json
end

get '/test_connection' do
  content_type :json
  j_data = build.test_connection
  { :data => j_data }.to_json
end

post '/status' do
  data = JSON.parse(request.env["rack.input"].read)
  build.set_number(data["build"]["number"])
  build.update(build.phase_for(data))
end

post '/masters' do
  data = JSON.parse(request.env["rack.input"].read)
  build.update_masters(data)
end

post '/whodunit' do
  data = JSON.parse(request.env["rack.input"].read)
  build.update_whodunit(data)
end

post "/custom" do
  input = JSON.parse(request.env["rack.input"].read)
  build.update(input["state"] || "unknown")
end

post "/deploying" do
  build.update("deploying")
end

post "/green" do
  build.update("green")
end

def build
  @build ||= Build.new
end
