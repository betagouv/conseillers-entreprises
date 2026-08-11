module Admin
  module Patches
    module FlashMessages
      ## !! Monkey-patch override !!
      # Sanitize the flash messages to allow (some) html
      def flash_messages
        super.transform_values { sanitize it }
      end
    end

    ActiveAdmin::ViewHelpers.include FlashMessages
  end
end
