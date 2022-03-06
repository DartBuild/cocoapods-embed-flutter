require 'cocoapods-embed-flutter/flutter/pubspec'

module Flutter
  class Dependency
    attr_reader :name, :requirements, :parent_spec, :is_dev_dependency

    def initialize(name, requirements, parent_spec, dev_dependency = false)
      raise StandardError, 'A flutter dependency requires a name.' unless name
      raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::PubSpec)
      @name = name
      @requirements = requirements
      @parent_spec = parent_spec
      @is_dev_dependency = dev_dependency
    end

    def self.create_from_hash(hash, parent_spec, dev_dependency = false)
      raise StandardError, 'A flutter dependency requires a parent pubspec.' unless parent_spec.is_a?(Flutter::PubSpec)
      hash.keys.map { |key| Flutter::Dependency.new(key, hash[key], parent_spec, dev_dependency) }
    end

    def is_local
      requirements.is_a?(Hash) && requirements.include?('path')
    end

    def spec
      Flutter::PubSpec.new(File.expand_path(path, File.dirname(parent_spec.file_path)))
    end

    def install
      spec.setup if is_local
    end

    def method_missing(m, *args, &block)
      if requirements.is_a?(Hash) && requirements.include?(m.to_s)
        return requirements[m.to_s]
      end
      super.method_missing(m, *args, &block)
    end
  end
end