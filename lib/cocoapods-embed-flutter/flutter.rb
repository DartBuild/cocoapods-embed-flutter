# The Flutter modules name-spaces all the classes for Flutter.
#
module Flutter
  # The flutter command name.
  #
  NAME = 'flutter'.freeze
  # The directory name for flutter specific
  # files in a flutter project.
  #
  DIR_NAME = 'Flutter'.freeze
  # The Pub modules name-spaces all the classes for Flutter Pub.
  #
  module Pub
    # The file name for flutter specification declaration.
    #
    SPEC_FILE = 'pubspec.yaml'.freeze
    # The folder name containing flutter dependencies cache files.
    #
    TOOL_DIR = '.dart_tool'.freeze
    # The cache file name for flutter projects.
    #
    CACHE_FILE = 'package_config.json'.freeze

    require 'cocoapods-embed-flutter/flutter/downloader'
    require 'cocoapods-embed-flutter/flutter/external_sources'

    autoload :Dependency,  'cocoapods-embed-flutter/flutter/dependency'
    autoload :Spec,        'cocoapods-embed-flutter/flutter/pubspec'
  end
end