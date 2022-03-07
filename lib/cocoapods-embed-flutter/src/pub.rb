require 'cocoapods-embed-flutter/gem_version'
require 'cocoapods-embed-flutter/flutter/pubspec'
require 'cocoapods-embed-flutter/flutter/external_sources'

module Pod
  class Podfile
    module DSL
      def pub(name = nil, *requirements)
        pubspec = Flutter::Pub::ExternalSources.fetchWithNameAndOptions(name, requirements)
        pubspec.setup
        raise StandardError, "Invalid flutter module: '#{name}'." unless File.exists?(pubspec.pod_helper_path)
        install_flutter_pods_for_pubspec(pubspec)
      end

      def install_flutter_pods_for_pubspec(pubspec)
        raise ArgumentError, "Invalid `pubspec` argument." unless pubspec.is_a?(Flutter::Pub::Spec)
        load pubspec.pod_helper_path
        install_all_flutter_pods(pubspec.project_path)
      end
    end
  end
end