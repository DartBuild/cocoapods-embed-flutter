# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-embed-flutter/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = CocoapodsEmbedFlutter::NAME
  spec.version       = CocoapodsEmbedFlutter::VERSION
  spec.authors       = ['Soumya Ranjan Mahunt']
  spec.email         = ['devsoumyamahunt@gmail.com']
  spec.description   = %q{Embed flutter plugins in iOS projects.}
  spec.summary       = %q{Embed flutter plugins in iOS projects.}
  spec.homepage      = 'https://github.com/soumyamahunt/cocoapods-embed-flutter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'yaml'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
