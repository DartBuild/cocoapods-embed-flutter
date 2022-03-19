require 'bundler/gem_tasks'

def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

def setup_project(pod_install = false)
  system('bundle install', exception: true)
  Bundler.with_unbundled_env do
    Dir.chdir('example/ios_app') do |path|
      system('bundle install', exception: true)
      system('bundle exec pod install', exception: true) if pod_install
    end
  end
end

desc 'Runs all the specs'
task :specs do
  sh "bundle exec bacon #{specs('**')}"
end

desc 'Setup example project'
task :demo do
  setup_project(true)
end

desc 'Update lock files'
task :update do
  setup_project
end

desc 'Publish to cocoapods plugins if not present'
task :publish do
  require 'rubygems'
  gem = Gem::Specification::load(Dir['*.gemspec'].first)

  require 'cocoapods'
  require 'pod/command/plugins_helper'
  known_plugins = Pod::Command::PluginsHelper.known_plugins
  return if known_plugins.one? { |plugin| plugin['gem'] == gem.name }

  require 'github_api'
  return if Github.search.issues(
    q: "#{gem.name} user:CocoaPods repo:CocoaPods/cocoapods-plugins in:title"
  ).items.count > 0
  system('pod plugins publish', exception: true)
end

task :default => :specs

