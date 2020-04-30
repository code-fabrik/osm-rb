require 'typhoeus'

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
  end
end
