require 'cocoapods-embed-flutter/flutter/dependency'
require 'yaml'

module Flutter
  NAME = 'flutter'.freeze
  DIR_NAME = 'Flutter'.freeze

  module Pub
    SPEC_FILE = 'pubspec.yaml'.freeze
    TOOL_DIR = '.dart_tool'.freeze
    CACHE_FILE = 'package_config.json'.freeze

    class Spec
      attr_reader :defined_in_file

      def initialize(path)
        @data = YAML.load_file path
        @defined_in_file = path
      end

      def self.find_file(name, path)
        path = File.expand_path(path, Dir.pwd)

        if File.basename(path) == Pub::SPEC_FILE
          return path
        elsif Dir.exists?(File.expand_path(name, path)) && File.exists?(File.expand_path(Pub::SPEC_FILE, File.expand_path(name, path)))
          return File.expand_path(Pub::SPEC_FILE, File.expand_path(name, path))
        elsif File.exists?(File.expand_path(Pub::SPEC_FILE, path))
          return File.expand_path(Pub::SPEC_FILE, path)
        else
          return nil
        end
      end

      def self.find(name, path)
        pubspec_path = find_file(name, path)
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec_path
        pubspec = Spec.new(pubspec_path)
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec.name == name
        return pubspec
      end

      def module?
        return false unless @data.include?(Flutter::NAME)
        return @data[Flutter::NAME].is_a?(Hash) && @data[Flutter::NAME].include?('module')
      end

      def project_path
        File.dirname(defined_in_file)
      end

      def package_cache_path
        File.join(project_path, Pub::TOOL_DIR, Pub::CACHE_FILE)
      end

      def pod_helper_path
        File.join(project_path, '.ios', Flutter::DIR_NAME, 'podhelper.rb') if module?
      end

      def dependencies
        return [] unless @data.include?('dependencies')
        Flutter::Pub::Dependency.create_from_hash(@data['dependencies'], self)
      end

      def dev_dependencies
        return [] unless @data.include?('dev_dependencies')
        Flutter::Pub::Dependency.create_from_hash(@data['dev_dependencies'], self)
      end

      def all_dependencies
        dependencies + dev_dependencies
      end

      def setup?
        File.exists?(package_cache_path) && (!module? || File.exists?(pod_helper_path))
      end

      def setup
        return if setup?
        pup_get
        all_dependencies.each(&:install)
      end 

      def pup_get
        Dir.chdir(project_path) { |path| system('flutter pub get', exception: true) }
      end

      def method_missing(m, *args, &block)
        if @data.include?(m.to_s)
          return @data[m.to_s]
        end
        super.method_missing(m, *args, &block)
      end
    end
  end
end