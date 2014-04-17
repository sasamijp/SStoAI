# -*- encoding: utf-8 -*-

require 'sinatra'

helpers do

end

before do

end

get '/sstoai' do

  erb :index

end

post '/sstoai' do

  @name = @params[:name]
  erb :index

end
