require 'cocoapods-embed-flutter/gem_version'
require 'cocoapods-embed-flutter/flutter/pubspec'

module CocoapodsEmbedFlutter
  module FlutterModule
    def flutter_module(name = nil, *requirements)
      raise StandardError, 'A flutter module requires a name.' unless name

      options = requirements.last
      raise StandardError, "No options for flutter module: '#{name}'." unless options.is_a?(Hash)

      path = options[:path]
      raise StandardError, "No path for flutter module: '#{name}'." unless path

      path = File.expand_path(path, Dir.pwd)
      if File.basename(path) == Flutter::PUBSPEC_FILENAME
        pubspec = Flutter::PubSpec.new(path)
        raise StandardError, "Invalid pubspec path: '#{path}' for flutter module: '#{name}'." unless pubspec.name == name
        path = File.dirname(path)
      elsif Dir.exists?(File.expand_path(name, path)) && File.exists?(File.expand_path(Flutter::PUBSPEC_FILENAME, File.expand_path(name, path)))
        module_path = File.expand_path(name, path)
        pubspec = Flutter::PubSpec.new(File.expand_path(Flutter::PUBSPEC_FILENAME, module_path))
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec.name == name
        path = module_path
      elsif File.exists?(File.expand_path(Flutter::PUBSPEC_FILENAME, path))
        pubspec = Flutter::PubSpec.new(File.expand_path(Flutter::PUBSPEC_FILENAME, path))
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec.name == name
      else
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'."
      end

      pubspec.setup
      raise StandardError, "Invalid flutter module: '#{name}'." unless File.exists?(pubspec.pod_helper_path)

      load pubspec.pod_helper_path
      install_all_flutter_pods(path)
    end
  end
  
  # Registers for CocoaPods plugin hooks
  module Hooks
    Pod::HooksManager.register(CocoapodsEmbedFlutter::NAME, :post_install) do |installer, options|
      # Do nothing
    end
  end
end