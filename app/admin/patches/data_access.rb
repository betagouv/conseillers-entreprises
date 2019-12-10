module Admin
  module Patches
    module DataAccess
      ## !! Monkey-patch override !!
      # When filtering for “has_many through” associations, AA  may yield duplicate rows in ActiveAdmin
      # See #691
      def scoped_collection
        super.distinct
      end
    end

    ActiveAdmin::ResourceController.prepend DataAccess
  end
end
