# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-embed-flutter/gem_version.rb'

Gem::Specification.new do |spec|
  repo = 'DartBuild/cocoapods-embed-flutter'
  repo_url = "https://github.com/#{repo}"

  spec.name          = 'cocoapods-embed-flutter'
  spec.version       = CocoapodsEmbedFlutter::VERSION
  spec.authors       = ['Soumya Ranjan Mahunt']
  spec.email         = ['devsoumyamahunt@gmail.com']
  spec.description   = %q{Embed flutter modules in iOS projects.}
  spec.summary       = <<-DESC
  Straight forward way of declaring flutter modules as dependency for targets,
  just like cocoapods does with pods.
                         DESC
  spec.homepage      = repo_url
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'yaml'
  spec.add_dependency 'fileutils'
  spec.add_dependency 'cocoapods'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.metadata = {
    'bug_tracker_uri'   => "#{repo_url}/issues",
    'changelog_uri'     => "#{repo_url}/blob/main/CHANGELOG.md",
    'source_code_uri'   => repo_url,
    'github_repo'       => "git@github.com:#{repo}.git"
  }
end
