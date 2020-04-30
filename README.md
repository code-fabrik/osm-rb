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

OSM-rb exposes two distincts APIs.

### Calculator

The calculator helps you with everything regarding projections, tile names and bounds.

To create a calculator you have to pass it a zoom level, padding and the target map size

```ruby
padding = OpenStruct.new(x: 50, y: 40)
target_size = OpenStruct.new(x: 800, y: 600)
calculator = Calculator.new(padding, target_size)
```

Once you have created a calculator, you can use it to calculate and set the required zoom
level to fit your bounds

```ruby
path = [
  OpenStruct.new(lat: 46.95127, lng: 7.43878),
  OpenStruct.new(lat: 46.92771, lng: 7.44610),
  OpenStruct.new(lat: 46.94764, lng: 7.37527)
]
zoom = calculator.zoom_level(path)
zoom # => 13
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

The exporter allows you to donwload and store tile images. It is also able to automatically stitch
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
