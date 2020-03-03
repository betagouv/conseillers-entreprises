module Admin
  module Patches
    ## !! Monkey-patch overrides !!
    module DataAccess
      # When filtering for “has_many through” associations,
      # AA  may yield duplicate rows in ActiveAdmin
      # See #691
      def scoped_collection
        super.distinct
      end

      # Display errors in AA when failing to destroy an object
      # because of a PG::ForeignKeyViolation exception.
      # Inspired by https://github.com/activeadmin/activeadmin/issues/5369
      def destroy_resource(object)
        begin
          super
        rescue ActiveRecord::ActiveRecordError => e
          object.errors.add(:base, e.message)
          flash[:alert] = object.errors.full_messages.join(". ").html_safe
        end
      end
    end

    ActiveAdmin::ResourceController.prepend DataAccess
  end
end
