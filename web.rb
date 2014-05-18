require 'sinatra'

NUMBER_REGEX = /\d+/

set :public_folder, 'public'
set :views, settings.root + '/templates'

get '/' do
  erb :index
end

get '/credits' do
  erb :credits
end

get '/panda' do
  erb :panda
end

def image_for (width, height, grayscale = false)
  size = "#{width}x#{height}"

  if grayscale
    thumb = File.dirname(__FILE__) + "/thumbs/#{size}.jpg"
  else
    thumb = File.dirname(__FILE__) + "/thumbs/g/#{size}.jpg"
  end

  unless File.exists?(thumb) and (Time.now - File.stat(thumb).mtime <= 3600)
    FileUtils.mkdir_p(File.dirname(thumb))

    images = Dir.entries(File.dirname(__FILE__) + '/images').reject! { |x| x[0] == '.' }

    image = File.dirname(__FILE__) + '/images/' + images["#{params[:width]}x#{params[:height]}".hash % images.length]

    extra = ''

    extra += '-set colorspace Gray' if grayscale

    command = "convert #{image} -thumbnail #{size}^ -gravity center -extent #{size} #{extra} #{thumb}"

    output = `#{command} 2>&1`

    raise "couldn't run #{command}: #{output}" unless $?.success?
  end

  thumb
end

get '/:width/:height' do
  raise Sinatra::NotFound unless params[:width].match NUMBER_REGEX and params[:height].match NUMBER_REGEX

  send_file image_for(params[:width], params[:height])
end

get '/g/:width/:height' do
  raise Sinatra::NotFound unless params[:width].match NUMBER_REGEX and params[:height].match NUMBER_REGEX

  send_file image_for(params[:width], params[:height], true)
end