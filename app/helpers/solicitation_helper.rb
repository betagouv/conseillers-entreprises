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

  ## Google Ads helpers
  # Our ads params are
  # pk_campaign=googleads-{campaignid}
  # pk_kwd={creative}-{keyword}
  def link_to_tracked_campaign(solicitation)
    campaign_components = solicitation.pk_campaign.split('-', 2)
    if campaign_components.first == 'googleads'
      link_to solicitation.pk_campaign, "https://ads.google.com/aw/adgroups?campaignId=#{campaign_components.last}"
    else
      solicitation.pk_campaign
    end
  end

  def link_to_tracked_ad(solicitation)
    campaign_components = solicitation.pk_campaign.split('-', 2)
    if campaign_components.first == 'googleads'
      keyword_components = solicitation.pk_kwd.split('-', 2)
      link_to solicitation.pk_kwd, "https://ads.google.com/aw/ads/versions?adId=#{keyword_components.first}"
    else
      solicitation.pk_kwd
    end
  end
end
