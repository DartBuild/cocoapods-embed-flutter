require 'cocoapods-embed-flutter/flutter/pubspec'

module Flutter
  module Pub
    class Dependency
      attr_reader :name, :requirements, :parent_spec, :is_dev_dependency

      def initialize(name, requirements, parent_spec, dev_dependency = false)
        raise StandardError, 'A flutter dependency requires a name.' unless name
        raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::Pub::Spec)
        @name = name
        @requirements = requirements
        @parent_spec = parent_spec
        @is_dev_dependency = dev_dependency
      end

      def self.create_from_hash(hash, parent_spec, dev_dependency = false)
        raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::Pub::Spec)
        hash.keys.map { |key| Dependency.new(key, hash[key], parent_spec, dev_dependency) }
      end

      def local?
        requirements.is_a?(Hash) && requirements.include?('path')
      end

      def spec
        Spec.find(name, File.expand_path(path, File.dirname(parent_spec.defined_in_file)))
      end

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