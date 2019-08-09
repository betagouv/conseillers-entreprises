module AdminHelper
  def intervention_zone_description(many_communes)
    summary = many_communes.intervention_zone_summary

    descriptions = summary[:territories].map do |hash|
      territory = hash[:territory]
      link = link_to(territory, admin_territory_path(territory))
      description = "#{link} : #{hash[:included]} / #{territory.communes.count}"

      if hash[:included] < territory.communes.count
        params = many_communes.is_a?(Antenne) ? { antenne: many_communes } : { expert: many_communes }
        confirm_message = I18n.t('active_admin.territory.confirm_assign_entire_territory', territory: territory, many_communes: many_communes)
        use_entire_territory_link = link_to(
          I18n.t('active_admin.territory.assign_entire_territory'),
          assign_entire_territory_admin_territory_path(territory, params),
          method: :post,
          data: { confirm: confirm_message }
        )
        description = "#{description} — #{use_entire_territory_link}"
      end

      description.html_safe
    end

    other = summary[:other]
    if other > 0
      descriptions << "#{I18n.t('other')} : #{other}"
    end

    descriptions.join("<br/>").html_safe
  end

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

  def status_tag_status_params(status)
    # Note: “status” is a property of Match and Need, but status_tag is also an ActiveAdmin helper
    css_class = { taking_care: 'warning', done: 'ok', not_for_me: 'error' }[status.to_sym]
    title = StatusHelper::status_description(status, :short)
    [title, class: css_class]
  end

  ::ActiveAdmin::CSVBuilder.module_eval do
    def column_count(attribute)
      column(attribute) { |object| object.send(attribute).size }
    end

    def column_list(association)
      column(association) { |object| object.send(association).map(&:to_s).join('/') }
    end
  end
end
