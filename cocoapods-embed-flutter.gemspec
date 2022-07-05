# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-embed-flutter/gem_version.rb'

Gem::Specification.new do |spec|
  repo     = 'DartBuild/cocoapods-embed-flutter'
  github   = 'https://github.com'
  repo_url = "#{github}/#{repo}"
  doc_url  = 'https://www.rubydoc.info/gems/cocoapods-embed-flutter'

  spec.name          = 'cocoapods-embed-flutter'
  spec.version       = CocoapodsEmbedFlutter::VERSION
  spec.homepage      = repo_url
  spec.license       = 'MIT'
  spec.authors       = ['Soumya Ranjan Mahunt']
  spec.email         = ['soumya.mahunt@gmail.com']
  spec.summary       = %q{Embed flutter modules in iOS projects.}
  spec.description   = <<-EOF
    Straight forward way of declaring flutter modules as dependency for targets,
    just like cocoapods does with pods.
  EOF

  spec.files         = `git ls-files`.split($/).grep_v(%r{^(example|.github)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'yaml'
  spec.add_runtime_dependency 'fileutils'
  spec.add_runtime_dependency 'cocoapods'
  spec.add_runtime_dependency 'concurrent-ruby'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.required_ruby_version = '>= 2.6'
  spec.metadata = {
    'bug_tracker_uri'   => "#{repo_url}/issues",
    'changelog_uri'     => "#{repo_url}/blob/v#{spec.version}/CHANGELOG.md",
    'documentation_uri' => "#{doc_url}/#{spec.version}",
    'source_code_uri'   => "#{repo_url}/tree/v#{spec.version}",
    'github_repo'       => "git@github.com:#{repo}.git",
    'funding_uri'       => "#{github}/sponsors/soumyamahunt"
  }
end
