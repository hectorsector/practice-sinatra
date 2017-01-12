require 'rubygems'
require 'sinatra'
require 'json'
require_relative 'collaborators'

jsontest = "none"

post '/payload' do
  push = JSON.parse(request.body.read)
  puts "I got some JSON: #{push.inspect}"
  jsontest = "I got some JSON: #{push.inspect}"
  #Collaborator.add repo_name: "cop1000/201720", issue_num: 1, team_num: "2233396"
  Collaborator.add repo_name: "cop1000/scratch", issue_num: 4, team_num: "2233396"
end

get '/' do
  jsontest
end

get '/about' do
  "I'm Briana and I love waffles."
end

get '/hello/:name/' do
  "Hello there, #{params[:name]}."
end

get '/hello/:name/:city' do
  "Hey there #{params[:name]} from #{params[:city]}."
end
