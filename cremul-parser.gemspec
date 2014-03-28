# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cremul/version'

Gem::Specification.new do |gem|
  gem.name          = "cremul-parser"
  gem.version       = Cremul::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["Per Spilling"]
  gem.email         = ["per@kodemaker.no"]
  gem.summary       = %q{A parser for CREMUL payment transaction files}
  gem.description   = %q{A parser for CREMUL payment transaction files. It parses the CREMUL file and creates a Ruby object structure corresponding to the elements in the file.}
  gem.homepage      = "https://github.com/perspilling/cremul-parser"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake', '~> 10'
end
