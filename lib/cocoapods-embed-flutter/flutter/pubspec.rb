require 'cocoapods-embed-flutter/flutter'
require 'yaml'
require 'open3'
require 'concurrent'
require 'cocoapods'

module Flutter
  module Pub
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
        elsif Dir.exists?(File.expand_path(name, path)) &&
         File.exists?(File.expand_path(Pub::SPEC_FILE, File.expand_path(name, path)))
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
      #         dependencies cache file.
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
      #         specification depends upon and are included in app release.
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

      # Runs `flutter pub get` on project directory concurrently.
      #
      # @return [Concurrent::Promises::Future, Nil]
      #         {Nil} if `pub get` running/completed, otherwise
      #         runs `flutter pub get` task in background
      #         and returns its future.
      #
      def pub_get
        future = @@current_pubgets[self]
        return nil if !future.nil?
        future = Concurrent::Promises.future do
          stdout, stderr, status = Open3.capture3('flutter pub get', :chdir => self.project_path)
          :result
        end
        @@current_pubgets[self] = future
        return Concurrent::Promises.zip(future, *all_dependencies.map(&:install).compact)
      end

      # See if two {Spec} instances refer to the same pubspecs.
      #
      # @return [Boolean] whether or not the two {Spec} instances refer to the
      #         same projects.
      #
      def ==(other)
        self.class === other &&
         other.defined_in_file == defined_in_file &&
         other.instance_variable_get(:@data) == @data
      end

      # @return [Fixnum] A hash identical for equals objects.
      #
      def hash
        [defined_in_file, @data].hash
      end

      alias eql? ==

      # Allows accessing top level values in `pubspec.yaml`,
      # i.e. name, description, version etc.
      #
      # @param    [Symbol] m
      #           top level key value to access,
      #           i.e. name, description etc.
      #
      # @return depending on accessed value type in `pubspec.yaml`.
      #
      # @raise [NoMethodError] if no method or custom attribute exists by
      #        the attribute name in pubspec.
      #
      def method_missing(m, *args, &block)
        if @data.include?(m.to_s)
          return @data[m.to_s]
        end
        super.method_missing(m, *args, &block)
      end

      private

      # A hash containing all `pub get` promises.
      @@current_pubgets = {}
    end
  end
end