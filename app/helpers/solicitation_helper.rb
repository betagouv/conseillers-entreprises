module SolicitationHelper
  ## Google Ads helpers
  # Our ads params are
  # mtm_campaign=googleads-{campaignid}
  # mtm_kwd={creative}-{keyword}
  def link_to_tracked_campaign(solicitation)
    campaign_components = solicitation.campaign&.split('-', 2)
    if campaign_components.present? && campaign_components.first == 'googleads'
      link_to solicitation.campaign, "https://ads.google.com/aw/adgroups?campaignId=#{campaign_components.last}"
    else
      solicitation.campaign
    end
  end

  def link_to_tracked_ad(solicitation)
    campaign_components = solicitation.campaign&.split('-', 2)
    if campaign_components.present? && campaign_components.first == 'googleads'
      keyword_components = solicitation.provenance_detail.split('-', 2)
      link_to solicitation.provenance_detail, "https://ads.google.com/aw/ads/versions?adId=#{keyword_components.first}"
    else
      solicitation.provenance_detail
    end
  end

  STATUS_ACTION_COLORS = {
    in_progress: %w[yellow],
    processed: %w[grey],
    canceled: %w[red]
  }

  def status_action_link(solicitation, new_status, classes = %w[])
    name = Solicitation.human_attribute_value(:status, new_status, context: :action)
    path = update_status_conseiller_solicitation_path(solicitation, status: new_status)
    classes += STATUS_ACTION_COLORS[new_status.to_sym]
    tag.li class: 'fr-menu__item' do
      link_to name, path, method: :post, class: classes.join(' ')
    end
  end

  def subject_link(solicitation)
    if solicitation.diagnosis.present? && solicitation.diagnosis.needs.present?
      link_for_editable_subject(solicitation.diagnosis.needs.first)
    elsif solicitation.landing_subject.present?
      solicitation.landing_subject.title
    else
      I18n.t('helpers.solicitation_number', id: solicitation.id)
    end
  end

  def link_to_diagnosis(diagnosis)
    text = if diagnosis.step_completed?
      t('helpers.solicitation.view_completed_analysis')
    else
      t('helpers.solicitation.analysis_in_progress', step: diagnosis.human_attribute_value(:step))
    end

    link_to text, [:conseiller, diagnosis], class: 'button'
  end

  def display_solicitation_attribute(solicitation, attribute)
    if attribute == :provenance_detail && solicitation.campaign == 'entreprendre'
      link_to solicitation.send(attribute), partner_url(solicitation, full: true), title: "#{to_new_window_title(t('needs.show.origin_source_title'))}", target: '_blank', rel: 'noopener'
    elsif attribute == :siret
      link_to(solicitation.normalized_siret, show_with_siret_companies_path(solicitation.siret), data: { turbo: false })
    else
      solicitation.send(attribute)
    end
  end

  def partner_title(solicitation)
    return if solicitation.nil?
    if solicitation.origin_title.present? && solicitation.landing.partner_url.present?
      "#{solicitation.origin_title} (#{solicitation.landing.partner_url})"
    else
      partner_url(solicitation)
    end
  end

  def partner_url(solicitation, full: false)
    return if solicitation.nil?
    return solicitation.origin_url if solicitation.origin_url.present?
    return entreprendre_url(solicitation, full: full) if (solicitation.campaign == 'entreprendre' && solicitation.kwd.present?)
    return landing_partner_url(solicitation, full: full)
  end

  private

  def link_for_editable_subject(need)
    title = t('helpers.solicitation.modify_subject')
    path = needs_conseiller_diagnosis_path(need.diagnosis)
    aria_describedby = "tooltip-#{need.id}"
    tag.div do
      concat(link_to need.subject.label, path, title: title, 'aria-describedby': aria_describedby)
      concat(tag.span title, class: 'fr-tooltip fr-placement', id: "tooltip-#{need.id}", role: 'tooltip', 'aria-hidden': true)
    end
  end

  def entreprendre_url(solicitation, full: false)
    full ? "https://entreprendre.service-public.fr/vosdroits/#{solicitation.kwd}" : "https://entreprendre.service-public.fr"
  end

  def landing_partner_url(solicitation, full: false)
    full ? solicitation.landing.partner_full_url : solicitation.landing.partner_url
  end
end
