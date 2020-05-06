RSpec.describe OSM::Exporter do
  before(:all) do
    @png = File.read('spec/fixtures/tile.png')
    response = Typhoeus::Response.new(code: 200, body: @png)
    Typhoeus.stub(/tiles\.example\.com/).and_return(response)
    @tile = OpenStruct.new(x: 136485, y: 92249)
  end

  it "downloads the tiles" do
    exporter = OSM::Exporter.new('tiles.example.com/{z}/{y}/{x}.png', 18)
    images = exporter.download_tiles_as_blob([@tile])
    expect(images.length).to eq(1)
    expect(images[0]).to eq(@png)
  end

  it "crops image" do
    path = File.join(File.dirname(__FILE__), 'fixtures/tile.png')
    image = ChunkyPNG::Image.from_file(path)
    expect(image.width).to eq(256)
    expect(image.height).to eq(256)

    exporter = OSM::Exporter.new(nil, nil)
    image = exporter.crop(image, OpenStruct.new(x: 78, y: 78), OpenStruct.new(x: 100, y: 100))

    expect(image.width).to eq(100)
    expect(image.height).to eq(100)

    reference_path = File.join(File.dirname(__FILE__), 'fixtures/tile_cropped.png')
    reference = ChunkyPNG::Image.from_file(reference_path)
    expect(image.to_rgb_stream).to eq(reference.to_rgb_stream)
  end
end
