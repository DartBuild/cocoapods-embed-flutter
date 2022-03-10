module CocoapodsEmbedFlutter
  # Registers for CocoaPods plugin hooks
  module Hooks
    Pod::HooksManager.register('cocoapods-embed-flutter', :post_install) do |installer, options|
      # Do nothing
    end
  end
end