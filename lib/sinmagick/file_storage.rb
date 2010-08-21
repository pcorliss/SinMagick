require 'fileutils'
require 'sinmagick/storage_type'
require 'sinmagick/sin_image'

class SinMagick
  class FileStorage < StorageType

    def initialize(name,base_dir,read_priority, write_priority)
      @name = name
      @base_dir = base_dir
      @read_priority = read_priority
      @write_priority = write_priority
    end

    def read(token,file_name)
      path = @base_dir+token+'/'+file_name
      if File.exists?(path)
        return FileSystemImage.new(file_name,File.open(path))
      else
        STDERR::puts "File #{path} does not exist."
        return false
      end
    end

    def write(in_file,file_name,token)
      begin
        unless File.directory?(@base_dir+token)
          FileUtils.mkdir(@base_dir+token)
        end
        out_file = File.open(@base_dir+token+'/'+file_name,'w');
        out_file.write(in_file.get_raw)
        out_file.close
      rescue SystemCallError
        STDERR::puts "IO failed: " + $!
        return false
      end
      return true
    end
    
  end
end
