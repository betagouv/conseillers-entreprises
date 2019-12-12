module Admin
  module Helpers
    ## Additional helpers for the objects links and attributes within /admin
    #
    module AdminLinkTo
      def admin_link_to(object, association = nil, options = {})
        if association.nil?
          return link_to(object, polymorphic_path([:admin, object]))
        end

        klass = object.class
        reflection = klass.reflect_on_association(association)

        if reflection.collection?
          if options[:list]
            foreign_objects = object.send(association)
            if foreign_objects.present?
              links = foreign_objects.map { |foreign_object| link_to(foreign_object, polymorphic_path([:admin, foreign_object])) }
              links.join('</br>').html_safe
            else
              '-'
            end
          else # single link to list
            count = object.send(association).size
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
            link_to(text, polymorphic_path([:admin, foreign_klass], "q[#{inverse_path}_id_eq]": object))
          end
        else
          foreign_object = object.send(association)
          if foreign_object.present?
            link_to(foreign_object, polymorphic_path([:admin, foreign_object]))
          else
            '-'
          end
        end
      end

      def admin_attr(object, attribute)
        klass = object.class
        "#{klass.human_attribute_name(attribute)} : #{object.send(attribute)}"
      end
    end

    Arbre::Element.include AdminLinkTo
  end
end
