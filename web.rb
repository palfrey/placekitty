require 'sinatra'

get '/' do
  "Hello, world"
end

get '/:width/:height' do
  "#{params[:width]} x #{params[:height]}"
end