module SolicitationHelper
  def solicitation_background_style
    images = [
      'background/bakery-1868925.jpg',
      'background/construction-worker-569149.jpg',
      'background/office-1209640.jpg'
    ]

    "background-image: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)),
                       url(#{image_path images.sample})"
  end

  def needs_description(solicitation)
    needs_keys = solicitation.needs.select{ |_,v| v == "1" }.keys.sort
    localized_needs = needs_keys.map{ |key| I18n.t("solicitations.needs.short.#{key}") }
    tag.ul do
      localized_needs.map{ |need| tag.li(need) }.join.html_safe
    end
  end

  def link_to_google_ad_content(content_id)
    link_to content_id, "https://ads.google.com/aw/ads/versions?adId=#{content_id}"
  end

  def link_to_google_ad_campaign(campaign_id)
    link_to campaign_id, "https://ads.google.com/aw/adgroups?campaignId=#{campaign_id}"
  end
end
