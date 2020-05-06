RSpec.describe OSM::Builder do
  it "builds png" do
    path = [
      OpenStruct.new(lat: 46.95127, lng: 7.43878),
      OpenStruct.new(lat: 46.92771, lng: 7.44610),
      OpenStruct.new(lat: 46.94764, lng: 7.37527)
    ]
    padding = OpenStruct.new(x: 50, y: 40)
    target_size = OpenStruct.new(x: 800, y: 600)
    map_urls = [
      'https://a.map.example.com/{z}/{x}/{y}.png',
      'https://b.map.example.com/{z}/{x}/{y}.png',
      'https://c.map.example.com/{z}/{x}/{y}.png'
    ]
    hillshade_urls = [
      'https://a.hill.example.com/{z}/{x}/{y}.png',
      'https://b.hill.example.com/{z}/{x}/{y}.png',
      'https://c.hill.example.com/{z}/{x}/{y}.png'
    ]

    osm = OSM::Builder.new()

    img = osm.add_path(path)
             .set_padding(padding)
             .set_size(target_size)
             .add_layer(map_urls)
             .add_layer(hillshade_urls)
             .get_blob
    expect(image.width).to eq(target_size.x)
    expect(image.height).to eq(target_size.y)
  end
end
