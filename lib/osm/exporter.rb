module OSM
  TILE_SIZE = 256

  class Exporter
    attr_reader :tile_urls, :zoom

    def initialize(tile_urls, zoom)
      @tile_urls = Array(tile_urls)
      @zoom = zoom
    end

    def download_tiles(tiles)
      url = tile_urls.sample()
      hydra = Typhoeus::Hydra.new
      requests = tiles.map do |tile|
        tile_url = url.gsub('{x}', tile.x).gsub('{y}', tile.y).gsub('{z}', zoom)
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
