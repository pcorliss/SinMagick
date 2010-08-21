require 'aws/s3'
require 'sinmagick/storage_type'
require 'sinmagick/sin_image'

class SinMagick
  class S3Storage < StorageType

    def initialize(name,bucket,read_priority,write_priority,key,secret)
      @name = name
      @bucket = bucket
      @read_priority = read_priority
      @write_priority = write_priority
      @key = key
      @secret = secret
      @s3 = AWS::S3::Base.establish_connection!(
        :access_key_id     => key,
        :secret_access_key => secret
      )
    end

    def read(token,file_name)
      begin
        return S3Image.new(file_name,(AWS::S3::S3Object.find "#{token}/#{file_name}", @bucket))
      rescue AWS::S3::ResponseError => error
        STDERR::puts error.message
        return false
      end
    end

    #Should be receiving SinImage Class
    def write(in_file,file_name,token)
      target_file_name = token+'/'+file_name
      begin
        AWS::S3::S3Object.store(target_file_name,in_file.get_raw,@bucket,:content_type => in_file.get_mime)
      rescue AWS::S3::ResponseError => error
        STDERR::puts error.message
        return false
      end
      return target_file_name
    end

  end
end
