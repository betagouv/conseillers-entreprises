module Admin
  module Patches
    module Scopes
      ## !! Monkey-patch override !!
      # Add a :title html attribute to the top-level scopes
      def build_scope(scope, options)
        element = super

        tooltip = I18n.t('active_admin.scopes.tooltips.' + scope.id, default: '').presence
        element.set_attribute(:title, tooltip)

        element
      end
    end

    ActiveAdmin::Views::Scopes.prepend Scopes
  end
end
