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
    association_reflection = klass.reflect_on_association(association)

    if association_reflection.collection?
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
        foreign_klass = association_reflection.klass
        inverse = association_reflection.options[:inverse_of]
        link_to(text, polymorphic_path([:admin, foreign_klass], "q[#{inverse}_id_eq]": object))
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
    # Note: “status” is a property of Match and DiagnosedNeed, but status_tag is also an ActiveAdmin helper
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
