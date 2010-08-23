#Gems
require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
RMAGICK_BYPASS_VERSION_TEST = true
require 'RMagick'
require 'aws/s3'

#Core Classes
require 'fileutils'
require 'yaml'
require "base64"
require 'net/http'

#My Classes
require 'lib/sinmagick/transform'
require 'lib/sinmagick/storage_set'
require 'lib/sinmagick/s3_storage'
require 'lib/sinmagick/file_storage'
require 'lib/sinmagick/s3_image'
require 'lib/sinmagick/file_system_image'

::AppConfig = YAML.load_file("config/settings.yml")

# Handles base sinatra requests and initializes Storage Set
class SinMagick
  storset = StorageSet.new

  puts "Welcome to SinMagick"

  # Serves simple upload form for posting to web service. 
  # Provides both file upload and URL upload.
  get '/' do
    content_type 'text/html'
    '<html>
      <head>
      <title>SinMagick Upload</title>
      </head>
      <body>
      <h2>SinMagick Upload</h2>

      <h3>File Upload</h3>
      <form enctype="multipart/form-data"  method="POST" action="/upload">
      <input type="file" name="file">
      <input type="submit">
      </form>

      <h3>URL Upload</h3>
      <form method="POST" action="/upload/url">
      <input type="text" name="url" size="96"><br>
      <input type="submit">
      </form>
      </body>
      </html>'
  end

  get '/favicon.ico' do
    content_type AppConfig['fav_icon_mime']
    File.open(AppConfig['fav_icon']).read
  end

  # Serves a specified image file. Token is 
  # typically the selected hash of the original file.
  get '/:token/:file_name' do
    if img = storset.read(params[:token], params[:file_name])
      content_type img.get_mime
      img.get_raw
    else
      STDERR::puts "Unable to find file."
      halt 404
    end
  end

  # Transforms the orignal file
  get '/transform/:transform/:token/:file_name' do
    unless AppConfig['read_transforms'] && img = storset.read(params[:token], params[:file_name]+'.'+params[:transform])
      transform_array = Transform.parse_transform(params[:transform])
      unless img = storset.read(params[:token], params[:file_name])
        STDERR::puts "Unable to find file."
        halt 404
      end
      img.img_handle = Transform.apply_transform!(img.get_img_handle, transform_array)
      img.modified = true
      if AppConfig['write_transforms']
        storset.write(img, params[:file_name]+'.'+params[:transform], params[:token])
      end
    end
    content_type img.get_mime
    img.get_raw
  end
  
  # Takes file uploads with the 'file' parameter
  post '/upload' do
    unless params[:file] &&
           (tmpfile = params[:file][:tempfile]) &&
           (file_name = params[:file][:filename])
      halt 501, "No file selected"
    end
    newfile = FileSystemImage.new(file_name,tmpfile.open)
    token = newfile.get_hash
    storset.write(newfile, file_name, token)
    tmpfile.unlink
    return '/'+token+'/'+file_name
  end

  # Takes URL uploads with the 'url' parameter
  post '/upload/url' do
    unless params[:url]
      halt 401, "No url selected"
    end

    url = URI.parse(params[:url])
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    
    file_name = url.path.split('/').last
    if file_name.nil?
      file_name = url.host
    end

    tmpfile = Tempfile.new('SinMagick')
    tmpfile.open
    tmpfile.write res.body
    tmpfile.close
    newfile = FileSystemImage.new(file_name,tmpfile.open)
    token = newfile.get_hash
    storset.write(newfile, file_name, token)
    tmpfile.unlink
    return '/'+token+'/'+file_name
  end
end
