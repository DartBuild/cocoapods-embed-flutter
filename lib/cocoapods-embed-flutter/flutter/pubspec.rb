require 'cocoapods-embed-flutter/flutter/dependency'
require 'yaml'

module Flutter
  NAME = 'flutter'
  DIR_NAME = 'Flutter'
  PUBSPEC_FILENAME = 'pubspec.yaml'

  class PubSpec
    attr_reader :file_path

    def initialize(path)
      @data = YAML.load_file path
      @file_path = path
    end

    def is_module
      return false unless @data.include?(Flutter::NAME)
      return @data[Flutter::NAME].is_a?(Hash) && @data[Flutter::NAME].include?('module')
    end

    def pod_helper_path
      File.join(File.dirname(file_path), '.ios', Flutter::DIR_NAME, 'podhelper.rb') if is_module
    end

    def dependencies
      return [] unless @data.include?('dependencies')
      Flutter::Dependency.create_from_hash(@data['dependencies'], self)
    end

    def dev_dependencies
      return [] unless @data.include?('dev_dependencies')
      Flutter::Dependency.create_from_hash(@data['dev_dependencies'], self)
    end

    def all_dependencies
      dependencies + dev_dependencies
    end

    def setup
      if is_module
        pup_get unless File.exists?(pod_helper_path)
      else
        pup_get
      end

      all_dependencies.each(&:install)
    end 

    def pup_get
      Dir.chdir(File.dirname(file_path)) { |path| system('flutter pub get', exception: true) }
    end

    def method_missing(m, *args, &block)
      if @data.include?(m.to_s)
        return @data[m.to_s]
      end
      super.method_missing(m, *args, &block)
    end
  end
end