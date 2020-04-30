lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "osm"

Gem::Specification.new do |spec|
  spec.name          = "osm-rb"
  spec.version       = OSM::VERSION
  spec.authors       = ["Lukas_Skywalker"]
  spec.email         = ["lukas.diener@hotmail.com"]

  spec.summary       = "Manipulation and export of OSM map tiles"
  spec.description   = %w{OSM-rb allows you to manipulate and export OSM map tiles. This includes downloading
                          tiles,cropping to any specified region, drawing routes on the map and exporting them
                          as PNG files. }
  spec.homepage      = "https://github.com/code-fabrik/osm-rb"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/code-fabrik/osm-rb"
  spec.metadata["changelog_uri"] = "https://github.com/code-fabrik/osm-rb/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0.1"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "typhoeus", "~> 1.3.1"
end
