module Admin
  module Helpers
    module StatusStatusTag
      ## status_tag for a Match.status
      # Note: “status” is a property of Match and Need, but status_tag is also an ActiveAdmin helper
      def status_status_tag(status)
        css_class = { taking_care: 'warning', done: 'ok', not_for_me: 'error' }[status.to_sym]
        title = StatusHelper::status_description(status, :short)

        status_tag(title, class: css_class)
      end
    end

    Arbre::Element.include StatusStatusTag
  end
end
