module Admin
  module Patches
    module HeadStyle
      ## !! Monkey-patch override !!
      # Add the dynamic badges css tag to the activeadmin <head>
      def build_active_admin_head
        within super do
          text_node badges_css_tag
        end
      end
    end

    ActiveAdmin::Views::Pages::Base.prepend HeadStyle
  end
end
