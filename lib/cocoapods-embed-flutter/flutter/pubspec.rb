require 'cocoapods-embed-flutter/flutter/dependency'
require 'yaml'

module Flutter
  NAME = 'flutter'.freeze
  DIR_NAME = 'Flutter'.freeze

  module Pub
    SPEC_FILE = 'pubspec.yaml'.freeze
    TOOL_DIR = '.dart_tool'.freeze
    CACHE_FILE = 'package_config.json'.freeze

    # The Specification provides a DSL to describe a flutter project.
    # A project is defined as a library originating from a source.
    # A specification can support detailed attributes for modules of code
    # through dependencies.
    #
    # Usually it is stored in `pubspec.yaml` file.
    #
    class Spec
      # @return [String] the path where the specification is defined, if loaded
      #         from a file.
      #
      attr_reader :defined_in_file

      # @param  [String] path
      #         the path to the specification.
      #
      def initialize(path)
        @data = YAML.load_file path
        @defined_in_file = path
      end

      # Returns the path to `pubspec` with the given name and location to search.
      #
      # @param    [String] name
      #           the name of the project declared in `pubspec`.
      #
      # @param    [String] path
      #           where project or pubspec is located.
      #
      # @note       either the flutter module or the `pubspec` of the flutter module
      #             can be in the path. Optionally you can provide the `pubspec`
      #             file directly.
      #
      # @return   [String] path to the `pubspec` with the given name if present.
      #
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

      # Returns the path to `pubspec` with the given name and location to search.
      #
      # @param    [String] name
      #           the name of the project declared in `pubspec`.
      #
      # @param    [String] path
      #           where project or pubspec is located.
      #
      # @note       either the flutter module or the `pubspec` of the flutter module
      #             can be in the path. Optionally you can provide the `pubspec`
      #             file directly.
      #
      # @return   [Spec] the `pubspec` with the given name if present.
      #
      def self.find(name, path)
        pubspec_path = find_file(name, path)
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec_path
        pubspec = Spec.new(pubspec_path)
        raise StandardError, "Invalid path: '#{path}' for flutter module: '#{name}'." unless pubspec.name == name
        return pubspec
      end

      # @return [Boolean] If this specification is a module specification.
      #
      def module?
        return false unless @data.include?(Flutter::NAME)
        return @data[Flutter::NAME].is_a?(Hash) && @data[Flutter::NAME].include?('module')
      end

      # @return [String] the path to the flutter project.
      #
      def project_path
        File.dirname(defined_in_file)
      end

      # @return [String] the path to the flutter project
      # dependencies cache file.
      #
      def package_cache_path
        File.join(project_path, Pub::TOOL_DIR, Pub::CACHE_FILE)
      end

      # @return [String] the path to the flutter project.
      #
      def pod_helper_path
        File.join(project_path, '.ios', Flutter::DIR_NAME, 'podhelper.rb') if module?
      end

      # @return [Array<Dependency>] the list of all the projects this
      # specification depends upon and are included in app release.
      #
      def dependencies
        return [] unless @data.include?('dependencies')
        Dependency.create_from_hash(@data['dependencies'], self)
      end

      # @return [Array<Dependency>] the list of all the projects this
      #         specification depends upon only during development.
      #
      def dev_dependencies
        return [] unless @data.include?('dev_dependencies')
        Dependency.create_from_hash(@data['dev_dependencies'], self)
      end

      # @return [Array<Dependency>] the list of all the projects this
      #         specification depends upon.
      #
      def all_dependencies
        dependencies + dev_dependencies
      end

      # @return [Boolean] If the flutter project for this specification
      # has all its dependencies installed.
      #
      def setup?
        File.exists?(package_cache_path) && (!module? || File.exists?(pod_helper_path))
      end

      # Sets up the project installing all specified dependencies.
      #
      # @return void
      #
      def setup
        return if setup?
        pup_get
        all_dependencies.each(&:install)
      end

      # Runs `flutter pub get` on project directory.
      #
      # @return void
      #
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