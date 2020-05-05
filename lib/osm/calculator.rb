require 'ostruct'

module OSM
  class Calculator
    TILE_SIZE = 256
    attr_reader :zoom, :padding, :target_size

    def initialize(zoom, padding, target_size)
      @zoom = zoom
      @padding = padding
      @target_size = target_size
    end

    def self.get_zoom_level(path, padding, target_size)
      18.downto(1) do |level|
        d = Calculator.new(level, padding, target_size)
        path_size = d.path_pixel_dimensions(path)
        if path_size.x + padding.x <= target_size.x && path_size.y + padding.y <= target_size.y
          return level
        end
      end
      return 1
    end

    def pixels(path)
      crop = crop_dimensions(path)
      top_left = top_left_tile(path)
      path.map do |point|
        pixel = lat_lng_to_pixel(point)
        OpenStruct.new(x: pixel.x - (top_left.x * TILE_SIZE) - crop.x, y: pixel.y - (top_left.y * TILE_SIZE) - crop.y)
      end
    end

    def tiles(path)
      top_left = top_left_tile(path)
      bottom_right = bottom_right_tile(path)
      tiles = []
      (top_left.y..bottom_right.y).each do |y|
        (top_left.x..bottom_right.x).each do |x|
          tiles << OpenStruct.new(x: x, y: y)
        end
      end
      tiles
    end

    def top_left_tile(path)
      center = center_pixel(path)
      x = center.x - (target_size.x / 2)
      y = center.y - (target_size.y / 2)
      OpenStruct.new(x: (x / TILE_SIZE).floor, y: (y / TILE_SIZE).floor)
    end

    def bottom_right_tile(path)
      center = center_pixel(path)
      x = center.x + (target_size.x / 2)
      y = center.y + (target_size.y / 2)
      OpenStruct.new(x: (x / TILE_SIZE).floor, y: (y / TILE_SIZE).floor)
    end

    def center_pixel(path)
      top_left = path_top_left_pixel(path)
      bottom_right = path_bottom_right_pixel(path)
      delta = OpenStruct.new(x: bottom_right.x - top_left.x, y: bottom_right.y - top_left.y)
      OpenStruct.new(x: top_left.x + (delta.x / 2), y: top_left.y + (delta.y / 2))
    end

    def tile_dimensions(path)
      t = tiles(path)
      width = t.map(&:x).max - t.map(&:x).min
      height = t.map(&:y).max - t.map(&:y).min
      OpenStruct.new(x: width + 1, y: height + 1)
    end

    def path_pixel_dimensions(path)
      top_left = path_top_left_pixel(path)
      bottom_right = path_bottom_right_pixel(path)
      OpenStruct.new(x: bottom_right.x - top_left.x, y: bottom_right.y - top_left.y)
    end

    def crop_dimensions(path)
      center = center_pixel(path)
      top_left = top_left_tile(path)
      left = center.x - (top_left.x * TILE_SIZE) - (target_size.x / 2)
      top = center.y - (top_left.y * TILE_SIZE) - (target_size.y / 2)
      OpenStruct.new(x: left, y: top)
    end

    private

    def path_top_left_pixel(path)
      min_deg = path_min(path)
      max_deg = path_max(path)
      point = OpenStruct.new(lat: max_deg.lat, lng: min_deg.lng)
      lat_lng_to_pixel(point)
    end

    def path_bottom_right_pixel(path)
      min_deg = path_min(path)
      max_deg = path_max(path)
      point = OpenStruct.new(lat: min_deg.lat, lng: max_deg.lng)
      lat_lng_to_pixel(point)
    end

    def path_min(path)
      OpenStruct.new(lat: path.map(&:lat).min, lng: path.map(&:lng).min)
    end

    def path_max(path)
      OpenStruct.new(lat: path.map(&:lat).max, lng: path.map(&:lng).max)
    end

    def scale
      2 ** zoom
    end

    def lat_lng_to_pixel(lat_lng)
      lat_deg = lat_lng.lat
      lng_deg = lat_lng.lng
      lat_rad = lat_deg/180 * Math::PI
      n = scale
      x = ((lng_deg + 180.0) / 360.0 * n)
      y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n)
      OpenStruct.new(x: (x * TILE_SIZE).floor, y: (y * TILE_SIZE).floor)
    end

    def pixel_to_lat_lng(pixel)
      xtile = pixel.x / TILE_SIZE.to_f
      ytile = pixel.y / TILE_SIZE.to_f
      n = scale
      lon_deg = xtile / n * 360.0 - 180.0
      lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * ytile / n)))
      lat_deg = 180.0 * (lat_rad / Math::PI)
      OpenStruct.new(lat: lat_deg, lng: lon_deg)
    end

    def lat_lng_to_tile(lat_lng)
      point = lat_lng_to_pixel(lat_lng)
      OpenStruct.new(x: (point.x / TILE_SIZE).floor, y: (point.y / TILE_SIZE).floor)
    end

    def tile_to_lat_lng(pixel)
      tile = OpenStruct.new(x: pixel.x.floor, y: pixel.y.floor)
      pixel_to_lat_lng(tile)
    end
  end
end
