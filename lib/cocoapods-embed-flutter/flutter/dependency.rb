require 'cocoapods-embed-flutter/flutter'

module Flutter
  module Pub
    # Provides a DSL to describe a flutter dependency. A dependency is defined in
    # `pubspec.yaml` in  `dependencies` or `dev_dependencies` sections.
    #
    class Dependency
      # @return [String] the name of the dependency.
      #
      attr_reader :name
      # @return [String, Hash] the requirements for
      #          dependency as declred in parent `pubspec`.
      #
      attr_reader :requirements
      # @return [Spec] the parent specification where
      #         dependency declared.
      #
      attr_reader :parent_spec
      # @return [Boolean] If this specification is an app specification.
      #
      attr_reader :is_dev_dependency

      # @param  [String] name
      #         the name of the specification.
      #
      # @param [String, Hash] requirements
      #        the requirements for dependency as declred in `pubspec`
      #
      # @param [Spec] parent_specification
      #        the parent specification where dependency declared
      #
      # @param [Boolean] is_dev_dependency
      #        Whether the dependency only required during development
      #
      def initialize(name, requirements, parent_spec, dev_dependency = false)
        raise StandardError, 'A flutter dependency requires a name.' unless name
        raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::Pub::Spec)
        @name = name
        @requirements = requirements
        @parent_spec = parent_spec
        @is_dev_dependency = dev_dependency
      end

      # Returns dependencies from hash declared in `dependencies` or `dev_dependencies`
      # section in `pubspec.yaml` file.
      #
      # @param    [Hash] hash declared in `dependencies` or `dev_dependencies`
      #           section in `pubspec.yaml` file
      #
      # @param    [Spec] parent_specification
      #           the parent specification where dependency declared
      #
      # @param    [Boolean] is_dev_dependency
      #           Whether the dependency only required during development
      #
      # @return   [Array<Dependency>] dependencies from hash declared in `dependencies`
      #            or `dev_dependencies` section in `pubspec.yaml` file.
      #
      def self.create_from_hash(hash, parent_spec, dev_dependency = false)
        raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::Pub::Spec)
        hash.keys.map { |key| Dependency.new(key, hash[key], parent_spec, dev_dependency) }
      end

      # @return [Boolean] If this dependency is a local flutter project.
      #
      def local?
        requirements.is_a?(Hash) && requirements.include?('path')
      end

      # @return [Spec] for this dependency if this dependency is a local flutter project.
      #
      def spec
        Spec.find(name, File.expand_path(path, File.dirname(parent_spec.defined_in_file)))
      end

      # Install this dependency for the parent project.
      #
      # @return [void]
      #
      def install
        spec.setup if local?
      end

      def method_missing(m, *args, &block)
        if requirements.is_a?(Hash) && requirements.include?(m.to_s)
          return requirements[m.to_s]
        end
        super.method_missing(m, *args, &block)
      end
    end
  end
end