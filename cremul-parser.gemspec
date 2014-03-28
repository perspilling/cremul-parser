# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cremul/version'

Gem::Specification.new do |gem|
  gem.name          = "cremul-parser"
  gem.version       = Cremul::VERSION
  gem.authors       = ["Per Spilling"]
  gem.email         = ["per@kodemaker.no"]
  gem.summary       = %q{A Ruby parser for CREMUL payment transaction files.}
  gem.description   = %q{Based on the format specification from BSK: http://bsk.no/media/18244/CREMUL_BSK_v2_13_d96A-201112.pdf}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake', '~> 10'
end
