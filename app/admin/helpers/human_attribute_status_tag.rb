module Admin
  module Helpers
    module HumanAttributeStatusTag
      ## status_tag for an object attribute (typically an enum)
      # attribute_status_tag m, :status
      # status_tag m.human_attribute_value(:status), class: m.status
      def human_attribute_status_tag(object, attribute)
        status_tag(object.human_attribute_value(attribute), class: object.send(attribute))
      end
    end

    Arbre::Element.include HumanAttributeStatusTag
  end
end
