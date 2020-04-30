RSpec.describe OSM::Calculator do
  before(:all) do
    @path = [
      OpenStruct.new(lat: 46.95127, lng: 7.43878),
      OpenStruct.new(lat: 46.92771, lng: 7.44610),
      OpenStruct.new(lat: 46.94764, lng: 7.37527)
    ]
    @target_size = OpenStruct.new(x: 800, y: 600)
    @padding = OpenStruct.new(x: 40, y: 30)
    @zoom = 13
  end

  it "converts coordinates to pixels" do
    point = OpenStruct.new(lat: 41.85, lng: -87.65)
    c = OSM::Calculator.new(5, nil, nil)
    pixel = c.send(:lat_lng_to_pixel, point)
    expect(pixel.x).to eq(2101)
    expect(pixel.y).to eq(3045)
  end

  it "converts coordinates to tiles" do
    point = OpenStruct.new(lat: 41.85, lng: -87.65)
    c = OSM::Calculator.new(5, nil, nil)
    tile = c.send(:lat_lng_to_tile, point)
    expect(tile.x).to eq(8)
    expect(tile.y).to eq(11)
  end

  it "converts pixels to coordinates" do
    pixel = OpenStruct.new(x: 2101, y: 3045)
    c = OSM::Calculator.new(5, nil, nil)
    point = c.send(:pixel_to_lat_lng, pixel)
    expect(point.lat).to eq(41.869560826994544)
    expect(point.lng).to eq(-87.6708984375)
  end

  it "calculates zoom level" do
    zoom_level = OSM::Calculator.get_zoom_level(@path, @padding, @target_size)
    expect(zoom_level).to eq(13)
  end

  it "calculates tile names" do
    c = OSM::Calculator.new(@zoom, @padding, @target_size)
    tiles = c.tiles(@path)
    expect(tiles.count).to eq(12)
    (2882..2884).each do |y|
      (4263..4266).each do |x|
        expect(tiles[(y - 2882) * 4 + (x - 4263)]).to eq(OpenStruct.new(x: x, y: y))
      end
    end
  end

  it "calculates tile count" do
    c = OSM::Calculator.new(@zoom, @padding, @target_size)
    dimensions = c.tile_dimensions(@path)
    expect(dimensions).to eq(OpenStruct.new(x: 4, y: 3))
  end
end
