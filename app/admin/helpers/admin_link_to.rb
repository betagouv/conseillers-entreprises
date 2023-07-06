module Admin
  module Helpers
    ## Additional helpers for the objects links and attributes within /admin
    #
    module AdminLinkTo
      def admin_link_to(object, association = nil, options = {})
        if association.nil?
          return nil if object.nil?
          return link_to(object, polymorphic_path([:admin, object]))
        end

        empty_result = options[:blank_if_empty] ? '' : '-'
        klass = object.class
        reflection = klass.reflect_on_association(association)

        if reflection.collection? # `has_many` association
          if options[:list] # List of objects
            foreign_objects = object.send(association)
            if foreign_objects.present?
              links = foreign_objects.map { |foreign_object| link_to(foreign_object, polymorphic_path([:admin, foreign_object])) }
              links.join('<br/>').html_safe
            else
              empty_result
            end
          else # Single link with count
            count = object.send(association).size
            return empty_result if count == 0

            text = "#{count} #{klass.human_attribute_name(association, count: count).downcase}"
            foreign_klass = reflection.klass
            if reflection.options[:through].present?
              # I’m not using `reflection.through_reflection` on purpose:
              # when the through association is a HABTM, the reflectio returned by
              # `reflection.through_reflection` is missing the :inverse_of option that we need.
              # If we query the original klass for the reflection on the through association,
              # we get all the declared options.
              through_reflection = klass.reflect_on_association(reflection.options[:through])
              names = [reflection.inverse_of.options[:through], through_reflection.options[:inverse_of]]
              inverse_path = names.compact.join('_')
            else
              inverse_path = reflection.inverse_of.name
            end
            # Note: we always use `object.id` here, instead of relying on :to_param,
            # to make sure the Ransacker query makes sense. Maybe we could improve it by looking
            # at the reflection foreign key.
            link_to(text, polymorphic_path([:admin, foreign_klass], "q[#{inverse_path}_id_eq]": object.id))
          end
        else # `has_one` association
          foreign_object = object.send(association)
          if foreign_object.present?
            link_to(foreign_object, polymorphic_path([:admin, foreign_object]))
          else
            empty_result
          end
        end
      end

      def admin_attr(object, attribute)
        klass = object.class
        if klass.column_for_attribute(attribute).type == :datetime
          value = I18n.l(object.send(attribute), format: :admin)
        else
          object.send(attribute)
        end
        "#{klass.human_attribute_name(attribute)} : #{value}"
      end
    end

    Arbre::Element.include AdminLinkTo
  end
end
