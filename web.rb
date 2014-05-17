require 'sinatra'

get '/' do
  "Hello World!"
end

def image_for size
  images = Dir.entries(File.dirname(__FILE__) + '/images').reject! { |x| x[0] == '.' }

  File.dirname(__FILE__) + '/images/' + images["#{params[:width]}x#{params[:height]}".hash % images.length]
end

get '/:width/:height' do
  size = "#{params[:width]}x#{params[:height]}"

  thumb = File.dirname(__FILE__) + "/thumbs/#{size}.jpg"

  unless File.exists?(thumb) and (Time.now - File.stat(thumb).mtime <= 3600)
    image = image_for(size)

    FileUtils.mkdir_p(File.dirname(thumb))

    command = "convert #{image} -thumbnail #{size}^ -gravity center -extent #{size} #{thumb}"

    output = `#{command} 2>&1`

    raise "couldn't run #{command}: #{output}" unless $?.success?
  end

  send_file thumb, :type => :jpg
end