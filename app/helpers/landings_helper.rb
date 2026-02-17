# frozen_string_literal: true

module LandingsHelper
  def render_information_banner(landing, extra_classes = [])
    return if landing.information_banner.blank?

    content_tag(:div, class: ['fr-notice', 'fr-notice--warning', 'information-banner', extra_classes].flatten.join(' ')) do
      content_tag(:div, class: 'fr-container') do
        content_tag(:div, class: 'fr-notice__body') do
          concat content_tag(:span, '', class: 'fr-notice__title')
          concat content_tag(:div, sanitize(landing.information_banner), class: 'fr-notice__desc')
        end
      end
    end
  end
end
