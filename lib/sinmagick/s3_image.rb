require 'sinmagick/sin_image'

class SinMagick
  class S3Image < SinImage

    def initialize(file_name,s3_object)
      @file_name = file_name
      @s3_object = s3_object
      @modified = false
    end

    def get_raw
      if modified == true && @img_handle
        @img_handle.to_blob
      else
        @s3_object.value
      end
    end

    def get_img_handle
      unless @img_handle
        @img_handle = Magick::Image.read_inline(Base64.encode64(self.get_raw)).first
      end
      return @img_handle
    end

    def get_mime
      @s3_object.content_type
    end

    def get_file_handle
      @f_handle = Tempfile.new('SinMagick')
      @f_handle.open do |file|
        @s3_object.stream do |chunk|
          file.write chunk
        end
      end
      @f_handle.close
      @f_handle.pos = 0
      return @f_handle
    end
  end
end
