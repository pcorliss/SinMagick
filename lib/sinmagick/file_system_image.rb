require 'sinmagick/sin_image'

class SinMagick
  class FileSystemImage < SinImage
    def initialize(file_name,file_handle)
      @file_name = file_name
      @f_handle = file_handle
      @modified = false
    end

    def get_raw
      if modified == true && @img_handle
        return @img_handle.to_blob
      else
        @f_handle.pos=0
        @f_handle.read
      end
    end

    def get_img_handle
      unless @img_handle
        @f_handle.pos=0
        @img_handle = Magick::Image.read(@f_handle).first
      end
      return @img_handle
    end

    def get_mime
      if @img_handle
        return @img_handle.mime_type
      else
        return self.get_img_handle.mime_type
      end
    end

    def get_file_handle
      @f_handle.pos = 0
      return @f_handle
    end
  end
end
