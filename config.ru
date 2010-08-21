#require ::File.dirname(__FILE__) + "/lib/sinmagick.rb"

#SinMagick.set :environment, ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :production
#run SinMagick


require 'sinmagick'
run Sinatra::Application