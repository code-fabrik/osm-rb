module OSM
  class Builder
    OSM_PATH_DEFAULT_COLOR = { r: 255, g: 0, b: 0 }
    attr_reader :path, :padding, :size, :layers

    def initialize
      @path = OpenStruct.new(path: [], color: OSM_PATH_DEFAULT_COLOR)
      @padding = OpenStruct.new(x: 0, y: 0)
      @size = OpenStruct.new(x: 400, y: 300)
      @layers = []
    end

    def add_path(path, color = OSM_PATH_DEFAULT_COLOR)
      @path = OpenStruct.new(path: path, color: color)
      self
    end

    def set_padding(padding)
      @padding = padding
      self
    end

    def set_size(size)
      @size = size
      self
    end

    def add_layer(urls, max_zoom = 18, min_zoom = 1)
      @layers << OpenStruct.new(urls: urls, max_zoom: max_zoom, min_zoom: min_zoom)
      self
    end

    def get_blob
      calculator = OSM::Calculator.new(zoom, padding, size)
      tiles = calculator.tiles(path.path)
      coordinates = calculator.pixels(path.path)
      tile_dimensions = calculator.tile_dimensions(path.path)
      crop_dimensions = calculator.crop_dimensions(path.path)

      img = nil

      layers.each do |layer|
        next if zoom > layer.max_zoom || zoom < layer.min_zoom
        begin
          exporter = OSM::Exporter.new(layer.urls, zoom)
          tile_images = exporter.download_tiles_as_blob(tiles)
          layer_img = exporter.stitch(tile_images, tile_dimensions)
          layer_img = exporter.crop(layer_img, crop_dimensions, size)

          if img.nil?
            img = layer_img
          else
            img = exporter.blend(layer_img, img)
          end
        rescue ChunkyPNG::SignatureMismatch => e
          # no op?
        end
      end

      exporter = OSM::Exporter.new(nil, zoom)
      img = exporter.draw_line(img, coordinates, path.color)

      img.to_blob(:fast_rgb)
    end

    private

    def zoom
      @zoom ||= OSM::Calculator.get_zoom_level(path.path, padding, size)
    end
  end
end
