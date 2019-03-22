module ActiveAdmin
  module LayoutHacks
    module ScopesWithTooltips
      def build_scope(scope, options)
        element = super

        tooltip = I18n.t('active_admin.scopes.tooltips.' + scope.id, default: '').presence
        element.set_attribute(:title, tooltip)

        element
      end
    end

    ActiveAdmin::Views::Scopes.prepend ScopesWithTooltips
  end
end
