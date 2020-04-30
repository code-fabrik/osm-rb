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
end
