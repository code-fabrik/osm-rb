require 'typhoeus'
require 'chunky_png'

module OSM
  class Exporter
    TILE_SIZE = 256
    attr_reader :tile_urls, :zoom

    def initialize(tile_urls, zoom)
      @tile_urls = Array(tile_urls)
      @zoom = zoom
    end

    def download_tiles_as_blob(tiles)
      url = tile_urls.sample()
      hydra = Typhoeus::Hydra.new
      requests = tiles.map do |tile|
        tile_url = url.gsub('{x}', tile.x.to_s).gsub('{y}', tile.y.to_s).gsub('{z}', zoom.to_s)
        request = Typhoeus::Request.new(tile_url)
        hydra.queue(request)
        request
      end
      hydra.run

      requests.map do |request|
        request.response.body
      end
    end

    def stitch(blobs, tile_dimensions)
      width = tile_dimensions.x
      height = tile_dimensions.y
      png = ChunkyPNG::Image.new(width * TILE_SIZE, height * TILE_SIZE, ChunkyPNG::Color::WHITE)
      count = 0
      (0...height).each do |y|
        (0...width).each do |x|
          tile = ChunkyPNG::Image.from_blob(blobs[count])
          png.replace!(tile, x * TILE_SIZE, y * TILE_SIZE)
          count += 1
        end
      end
      png
    end

    def draw_line(png, coordinates, rgb = { r: 255, g: 0, b: 0 })
      str0 = coordinates.map { |c| "(#{c.x},#{c.y})" }.join(' ')
      str1 = coordinates.map { |c| "(#{c.x+1},#{c.y})" }.join(' ')
      str2 = coordinates.map { |c| "(#{c.x},#{c.y+1})" }.join(' ')
      str3 = coordinates.map { |c| "(#{c.x-1},#{c.y})" }.join(' ')
      str4 = coordinates.map { |c| "(#{c.x},#{c.y-1})" }.join(' ')
      s = Time.now.to_f
      [str0, str1, str2, str3, str4].each do |str|
        png = png.polygon(str, ChunkyPNG::Color.rgb(rgb[:r], rgb[:g], rgb[:b]))
      end
      puts Time.now.to_f - s
      png
    end

    def crop(png, crop_dimensions, target_size)
      png.crop(crop_dimensions.x, crop_dimensions.y, target_size.x, target_size.y)
    end
  end
end
