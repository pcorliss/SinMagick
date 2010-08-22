#may need enumerable module for sorting below
require 'lib/sinmagick/storage_type'
require 'stringio'
require 'yaml'

class SinMagick
  class StorageSet

    def initialize
      @@storage_set = Array.new
      AppConfig['storage_set'].each do |stor|
        case stor['type']
        when 's3'
          self.add(S3Storage.new(
              stor['name'],
              stor['bucket'],
              stor['read_priority'],
              stor['write_priority'],
              stor['key'],
              stor['secret']
            ))
        when 'file'
          self.add(FileStorage.new(
              stor['name'],
              stor['base_dir'],
              stor['read_priority'],
              stor['write_priority']
            ))
        end
      end
    end

    def add(storage_item)
      @@storage_set.push(storage_item)
    end

    def remove(storage_item)
      @@storage_set.delete(storage_item)
    end

    def read(token,file_name)
      @@storage_set.sort_by { |stor| stor.read_priority }.each do |stor|
        if stor.read_priority < 0
          next
        end
        if file = stor.read(token,file_name)
          return file
        end
      end
      return false
    end

    def write(file,file_name,token)
      in_file = file
      priority = 0
      success = false
      @@storage_set.sort_by { |stor| stor.write_priority }.each do |stor|
        if stor.write_priority < 0
          next
        end
        if priority != stor.write_priority
          if success == false
            priority = stor.write_priority
          else
            break
          end
        end
        if stor.write(in_file,file_name,token)
          success = true
        else
          STDERR::puts "Failed to write to "+stor.name
        end
      end
      return success
    end

  end
end

