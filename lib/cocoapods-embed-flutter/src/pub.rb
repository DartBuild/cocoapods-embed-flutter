require 'cocoapods-embed-flutter/gem_version'
require 'cocoapods-embed-flutter/flutter'

# The Pod modules name-spaces all the classes and methods
# providing flutter specific functionality to podfile.
#
module Pod
  # The Podfile is a specification that describes the dependencies of the
  # targets of an Xcode project.
  #
  # It supports its own DSL and is stored in a file named `Podfile`.
  #
  # The Podfile creates a hierarchy of target definitions that store the
  # information necessary to generate the CocoaPods libraries.
  #
  class Podfile
    # The Podfile is a specification that describes the dependencies of the
    # targets of one or more Xcode projects. With Embed Flutter
    # it is possible to declare flutter module as dependency
    #
    # A Podfile can be very simple:
    #
    #     target 'MyApp'
    #     pub 'flutter_module', :path => '../'
    #
    # An example of a more complex Podfile can be:
    #
    #     platform :ios, '9.0'
    #     inhibit_all_warnings!
    #
    #     target 'MyApp' do
    #       pub 'flutter_module', :path => '../'
    #     end
    #
    #     target 'MyAppTests' do
    #       pub 'flutter_module_test', :path => '../'
    #     end
    #
    #     post_install do |installer|
    #       installer.pods_project.targets.each do |target|
    #         puts "#{target.name}"
    #       end
    #     end
    #
    #
    # @note       Currently only one flutter module per target is
    #             supported.
    #
    module DSL
      # Specifies a flutter module dependency of the project.
      #
      # A dependency requirement is defined by the name of the module and
      # optionally a list of requirements.
      #
      #
      # ### Using the files from a local path.
      #
      #  If you would like to use develop a flutter module in tandem with
      #  its client project you can use the `path` option.
      #
      #     pub 'flutter_module', :path => '../'
      #
      #  Using this option Embed Flutter will assume the given folder
      #  to be the root of the flutter module or the root of flutter module `pubspec` file
      #  or points to the `pubspec` file itself and will link the files directly from there
      #  in the Pods project. This means that your edits will persist to
      #  CocoaPods installations.
      #
      #  The referenced folder can be a checkout of your your favourite SCM or
      #  even a git submodule of the current repository.
      #
      #  Note that either the flutter module or the `pubspec` of the flutter module
      #  can be in the folder. Optionally you can provide the `pubspec` file directly.
      #
      #
      # ### From a flutter module in the root of a library repository.
      #
      # Sometimes you may want to use the bleeding edge version of a module. Or a
      # specific revision. If this is the case, you can specify that with your
      # pub declaration.
      #
      # To use the `master` or `main` branch of the repository:
      #
      #     pub 'flutter_module', :git => 'https://github.com/octokit/flutter_module.git'
      #
      #
      # To use a different branch of the repository:
      #
      #     pub 'flutter_module', :git => 'https://github.com/octokit/flutter_module.git', :branch => 'dev'
      #
      #
      # To use a tag of the repository:
      #
      #     pub 'flutter_module', :git => 'https://github.com/octokit/flutter_module.git', :tag => '0.7.0'
      #
      #
      # Or specify a commit:
      #
      #     pub 'flutter_module', :git => 'https://github.com/octokit/flutter_module.git', :commit => '082f8319af'
      #
      # The flutter module or its `pubspec` file is expected to be in the
      # root of the repository, if that's not the case specify relative path
      # to flutter project in repository.
      #
      #     pub 'flutter_module', :git => 'https://github.com/octokit/flutter_module.git', :tag => '0.7.0', :path => 'custom/flutter_module'
      #
      #
      # @note       This method allow a nil name and the raises to be more
      #             informative.
      #
      # @return     [void]
      #
      def pub(name = nil, *requirements)
        pubspec = Flutter::Pub::ExternalSources.fetchWithNameAndOptions(name, requirements)
        pubspec.setup
        raise StandardError, "Invalid flutter module: '#{name}'." unless File.exists?(pubspec.pod_helper_path)
        install_flutter_pods_for_pubspec(pubspec)
      end

      # Integrates flutter module provided in `pubspec`
      # to an Xcode project target.
      #
      # @param  [Flutter::Pub::Spec] pubspec
      #         the flutter module project specification.
      #
      # @return [void]
      #
      def install_flutter_pods_for_pubspec(pubspec)
        raise ArgumentError, "Invalid `pubspec` argument." unless pubspec.is_a?(Flutter::Pub::Spec)
        load pubspec.pod_helper_path
        install_all_flutter_pods(pubspec.project_path)
      end
    end
  end
end