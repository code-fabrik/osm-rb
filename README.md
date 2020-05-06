# OSM

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'osm-rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install osm-rb

## Usage

OSM uses the builder pattern to configure the map.

```ruby
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

osm.add_path(path)
   .set_padding(padding)
   .set_size(target_size)
   .add_layer(map_urls)
   .add_layer(hillshade_urls)
   .get_blob
```

## Low level API

The calculator helps you with everything regarding projections, tile names and bounds.

You can use the calculator to calculate and set the required zoom level to fit your bounds

```ruby
path = [
  OpenStruct.new(lat: 46.95127, lng: 7.43878),
  OpenStruct.new(lat: 46.92771, lng: 7.44610),
  OpenStruct.new(lat: 46.94764, lng: 7.37527)
]
padding = OpenStruct.new(x: 50, y: 40)
target_size = OpenStruct.new(x: 800, y: 600)

zoom_level = OSM::Calculator.get_zoom_level(path, padding, target_size)
zoom_level # => 13
```

Once you know the required zoom level, you can create a calculator. You always need to
pass it a zoom level, target padding and the target map size

```ruby
calculator = Calculator.new(padding, target_size)
```

Calculate required tiles to fit the map as specified

```ruby
tiles = calculator.tiles(path)
tiles[0].x # => 136485
tiles[0].y # => 92249
```

Calculate the number of tiles required

```ruby
dimensions = calculator.tile_dimensions(path)
dimensions.x # => 12
dimensions.y # => 8
```

### Exporter

The exporter allows you to download and store tile images. It is also able to automatically stitch
them together.

To create an exporter, you have to pass it an array of tile server url templates and a zoom level

```ruby
urls = [
  'https://a.tile.opentopomap.org/{z}/{x}/{y}.png',
  'https://b.tile.opentopomap.org/{z}/{x}/{y}.png',
  'https://c.tile.opentopomap.org/{z}/{x}/{y}.png'
]
zoom_level = 13
exporter = OSM::Exporter.new(urls, zoom_level)
```

Download the specified tiles

```ruby
tiles = [
  OpenStruct.new(lat: 46.95127, lng: 7.43878),
  OpenStruct.new(lat: 46.92771, lng: 7.44610),
  OpenStruct.new(lat: 46.94764, lng: 7.37527)
]
images = exporter.download_tiles_as_blob(tiles)
# images is an array of the binary data of the tiles
```

You can use any of the compatible [caches for Typhoeus](https://github.com/typhoeus/typhoeus#caching)
and follow their instructions.

To use a Redis cache

```ruby
require 'redis'
redis = Redis.new(...)
Typhoeus::Config.cache = Typhoeus::Cache::Redis.new(redis)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/code-fabrik/osm-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OSM project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/code-fabrik/osm-rb/blob/master/CODE_OF_CONDUCT.md).
