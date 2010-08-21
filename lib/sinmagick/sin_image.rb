require 'zlib'
require 'digest'

class SinMagick
  class SinImage
    attr_reader :file_name
    attr_accessor :modified
    attr_accessor :img_handle

    def get_hash
      case AppConfig['hash']
      when 'crc32'
        return Zlib.crc32(self.get_raw+AppConfig['password']).to_s(32)
      when 'md5'
        return Digest::MD5.hexdigest(self.get_raw+AppConfig['password']).hex.to_s(32)
      when 'sha1'
        return Digest::SHA1.hexdigest(self.get_raw+AppConfig['password']).hex.to_s(32)
      when 'sha2'
        return Digest::SHA2.hexdigest(self.get_raw+AppConfig['password']).hex.to_s(32)
      when 'none'
        return 't'
      end
    end
  end
end
