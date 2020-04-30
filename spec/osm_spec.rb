RSpec.describe OSM do
  it "has a version number" do
    expect(OSM::VERSION).not_to be nil
  end
end
