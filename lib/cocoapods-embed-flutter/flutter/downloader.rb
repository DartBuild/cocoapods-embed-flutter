require 'cocoapods'
require 'fileutils'

module Flutter
  module Pub
    module Downloader
      # Downloads a package from the given `request` to the given `target` location.
      #
      # @return [Response] The download response for this download.
      #
      # @param  [Request] request
      #         the request that describes the flutter project download.
      #
      # @param  [Pathname,Nil] target
      #         the location to which the flutter project should be downloaded.
      #
      # @param  [Boolean] can_cache
      #         whether caching is allowed.
      #
      # @param  [Pathname,Nil] cache_path
      #         the path used to cache flutter project downloads.
      #
      # @todo   Implement caching for remote sources.
      #
      def self.download(
        request,
        target,
        can_cache: true,
        cache_path: Pod::Config.instance.cache_root + 'Pods'
      )
        can_cache &&= !Pod::Config.instance.skip_download_cache

        request = Pod::Downloader.preprocess_request(request)

        # if can_cache
        #   raise ArgumentError, 'Must provide a `cache_path` when caching.' unless cache_path
        #   cache = Pod::Downloader::Cache.new(cache_path)
        #   result = cache.download_pod(request)
        # else
        #   raise ArgumentError, 'Must provide a `target` when caching is disabled.' unless target

        #   result, = Pod::Downloader.download_request(request, target)
        #   Pod::Installer::PodSourcePreparer.new(result.spec, result.location).prepare!
        # end
        raise ArgumentError, 'Must provide a `target` when caching is disabled.' unless target
        result, = Pod::Downloader.download_request(request, target)

        if target && result.location && target != result.location
          Pod::UI.message "Copying #{request.name} from `#{result.location}` to #{UI.path target}", '> ' do
            Pod::Downloader::Cache.read_lock(result.location) do
              FileUtils.rm_rf target
              FileUtils.cp_r(result.location, target)
            end
          end
        end
        result
      end
    end
  end
end