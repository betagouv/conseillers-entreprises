module AdminHelper
  def intervention_zone_description(many_communes)
    summary = many_communes.intervention_zone_summary
    descriptions = summary[:territories].map do |hash|
      territory = hash[:territory]
      link = link_to(territory, admin_territory_path(territory))
      "#{link} : #{hash[:included]} / #{territory.communes.count}".html_safe
    end
    other = summary[:other]
    if other > 0
      descriptions << "#{I18n.t('other')} : #{other}"
    end
    descriptions.join("<br/>").html_safe
  end

  def intervention_zone_short_description(many_communes)
    communes = many_communes.communes
    territories = many_communes.territories
    "#{territories.size} #{t('activerecord.models.territory', count: territories.size)} "\
    "(#{communes.size} #{t('activerecord.models.commune', count: communes.size)})"
  end
end
