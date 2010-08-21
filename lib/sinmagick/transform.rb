class SinMagick
  class Transform

    gravity = {
      "n" => Magick::NorthGravity,
      "s" => Magick::SouthGravity,
      "w" => Magick::WestGravity,
      "e" => Magick::EastGravity,
      "nw" => Magick::NorthWestGravity,
      "ne" => Magick::NorthEastGravity,
      "sw" => Magick::SouthWestGravity,
      "se" => Magick::SouthEastGravity,
      "c" => Magick::CenterGravity,
      "u" => Magick::UndefinedGravity
    }

    def Transform.parse_transform(transform_string)
      transform_array = Array.new
      transform_string.split(/-/).each do |transform|
        transform_type = transform[0,1]
        transform_array.push(Hash.new)
        transform_array.last["Type"] = transform_type
        transform[1,transform.length-1].split(/_/).each do |transform_arg|
          transform_array.last[transform_arg[0,1]] = transform_arg[1,transform_arg.length-1]
        end
      end
      return transform_array
    end

    def Transform.apply_transform!(img,transform_array)
      transform_array.each do |trans|
        case trans["Type"]
        when 'S'
          img = img.scale(trans['w'].to_i,trans['h'].to_i)
        when 'R'
          img = img.crop_resized(trans['w'].to_i,trans['h'].to_i,gravity[trans['g']])
        when 'A'
          img.change_geometry!(trans['w']+'x'+trans['h']) { |cols, rows, img|
            img.resize!(cols,rows)
          }
        when 'C'
          img = img.crop(trans['x'].to_i,trans['y'].to_i,trans['w'].to_i,trans['h'].to_i)
        when 'G'
          img = img.crop(gravity[trans['g']],trans['w'].to_i,trans['h'].to_i)
        when 'O'
          img = img.rotate(trans['a'].to_i)
        when 'B'
          img = img.quantize(256, Magick::GRAYColorspace)
        when 'P'
          img_density = img.rows.to_f * img.columns.to_f / img.filesize.to_f
          if img_density < trans['t'].to_i && img.format == 'PNG'
            img.format = 'JPEG'
          end
        when 'F'
          img.format = trans['f']
        else
          STDERR.puts "Unknown Transform: "+trans.inspect
        end
      end
      return img
    end
  end

end
