#require 'file_storage'
#require 's3_storage'

class SinMagick
  class StorageType
    attr_reader :name
    attr_reader :read_priority
    attr_reader :write_priority
  end
end
