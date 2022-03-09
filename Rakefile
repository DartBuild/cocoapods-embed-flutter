require 'bundler/gem_tasks'

def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

desc 'Runs all the specs'
task :specs do
  sh "bundle exec bacon #{specs('**')}"
end

desc 'Setup example project'
task :demo do
  system('bundle install', exception: true)
  Bundler.with_clean_env do
    Dir.chdir('example/ios_app') do |path|
      system('bundle install', exception: true)
      system('bundle exec pod install', exception: true)
    end
  end
end

task :default => :specs

