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

  def status_tag_status_params(status)
    # Note: “status” is a property of Match and Need, but status_tag is also an ActiveAdmin helper
    css_class = { taking_care: 'warning', done: 'ok', not_for_me: 'error' }[status.to_sym]
    title = StatusHelper::status_description(status, :short)
    [title, class: css_class]
  end
end
