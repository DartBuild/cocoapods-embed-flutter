# Similar to:
# https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/external_sources/abstract_external_source.rb
require 'cocoapods-embed-flutter/flutter/downloader'
require 'cocoapods'

module Flutter
  module Pub
    module ExternalSources
      SOURCE_KEYS = {
        :git  => [:tag, :branch, :commit, :submodules].freeze,
        :svn  => [:folder, :tag, :revision].freeze,
        :hg   => [:revision].freeze,
        :http => [:flatten, :type, :sha256, :sha1, :headers].freeze,
      }.freeze

      # Returns the path to `pubspec` with the given name and location to search.
      #
      # @param    [String] name
      #           the name of the project declared in `pubspec`.
      #
      # @param    [Hash] options
      #           requirement opttions for the source of project.
      #
      # @note       the source of project can either be local or all the remotes
      #             supported by `cocoapods-downloader`.
      #
      # @return   [Spec] the `pubspec` with the given name satisfying
      #           requirement options.
      #
      def self.fetchWithNameAndOptions(name, options)
        raise StandardError, 'A flutter module requires a name.' unless name

        options = options.last if options.is_a?(Array)
        raise StandardError, "No options specified for flutter module: '#{name}'." unless options.is_a?(Hash)

        if options.key?(:path)
          path = options[:path]
        elsif SOURCE_KEYS.keys.any? { |key| options.key?(key) }
          source = DownloaderSource.new(name, options, Pod::Config.instance.podfile_path)
          source.fetch(Pod::Config.instance.sandbox)
          path = source.normalized_pupspec_path
        else
          raise StandardError, "Invalid flutter module: '#{name}'."
        end

        return Spec.find(name, path)
      end

      # Provides support for fetching a specification file from a source handled
      # by the downloader. Supports all the options of the downloader
      #
      # @note The pubspec must be in the root of the repository 
      #       or in directory with the name provided 
      #
      class DownloaderSource
        # @return [String] the name of the Package described by this external source.
        #
        attr_reader :name

        # @return [Hash{Symbol => String}] the hash representation of the
        #         external source.
        #
        attr_reader :params

        # @return [String] the path where the podfile is defined to resolve
        #         relative paths.
        #
        attr_reader :podfile_path

        # @return [Boolean] Whether the source is allowed to touch the cache.
        #
        attr_reader :can_cache
        alias_method :can_cache?, :can_cache

        # Initialize a new instance
        #
        # @param [String] name @see #name
        # @param [Hash] params @see #params
        # @param [String] podfile_path @see #podfile_path
        # @param [Boolean] can_cache @see #can_cache
        #
        def initialize(name, params, podfile_path, can_cache = true)
          @name = name
          @params = params
          @podfile_path = podfile_path
          @can_cache = can_cache
        end

        # @return [Boolean] whether an external source source is equal to another
        #         according to the {#name} and to the {#params}.
        #
        def ==(other)
          return false if other.nil?
          name == other.name && params == other.params
        end


        public

        # @!group Subclasses hooks

        # Fetches the external source from the remote according to the params.
        #
        # @param  [Sandbox] sandbox
        #         the sandbox where the specification should be stored.
        #
        # @return [void]
        #
        def fetch(sandbox)
          pre_download(sandbox)
        end

        # @return [String] a string representation of the source suitable for UI.
        #
        def description
          strategy = Pod::Downloader.strategy_from_options(params)
          options = params.dup
          url = options.delete(strategy)
          result = "from `#{url}`"
          options.each do |key, value|
            result << ", #{key} `#{value}`"
          end
          result
        end

        # Return the normalized path for a pubspec for a relative declared path.
        #
        # @param  [String] declared_path
        #         The path declared in the podfile.
        #
        # @return [String] The uri of the pubspec appending the name of the file
        #         and expanding it if necessary.
        #
        # @note   If the declared path is expanded only if the represents a path
        #         relative to the file system.
        #
        def normalized_pupspec_path(declared_path)
          Spec.find_file(name, declared_path)
        end

        def normalized_pupspec_path
          Spec.find_file(name, target)
        end

        private

        # @! Subclasses helpers

        # Pre-downloads a Pod passing the options to the downloader and informing
        # the sandbox.
        #
        # @param  [Sandbox] sandbox
        #         The sandbox where the Pod should be downloaded.
        #
        # @note   To prevent a double download of the repository the pod is
        #         marked as pre-downloaded indicating to the installer that only
        #         clean operations are needed.
        #
        # @todo  The downloader configuration is the same of the
        #        #{PodSourceInstaller} and it needs to be kept in sync.
        #
        # @return [void]
        #
        def pre_download(sandbox)
          title = "Pre-downloading: `#{name}` #{description}"
          Pod::UI.titled_section(title,  :verbose_prefix => '-> ') do
            begin
              download_result = Downloader.download(download_request, target, :can_cache => can_cache)
            rescue Pod::DSLError => e
              raise Pod::Informative, "Failed to load '#{name}' pubspec: #{e.message}"
            rescue => e
              raise Pod::Informative, "Failed to download '#{name}': #{e.message}"
            end

            # spec = download_result.spec
            # raise Pod::Informative, "Unable to find a specification for '#{name}'." unless spec

            # since the podspec might be cleaned, we want the checksum to refer
            # to the json in the sandbox
            # spec.defined_in_file = nil

            # store_podspec(sandbox, spec)
            # sandbox.store_pre_downloaded_pod(name)
            # sandbox.store_checkout_source(name, download_result.checkout_options)
          end
        end

        def download_request
          Pod::Downloader::Request.new(
            :name => name,
            :params => params,
          )
        end

        def target
          return Pod::Config.instance.sandbox.pod_dir(name)
        end
      end
    end
  end
end