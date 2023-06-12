# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date) rescue nil
  end

  def annee_effectif(annee)
    return nil if annee.nil?
    "(#{annee})"
  end

  def inscription_registre(registre, value)
    label = I18n.t(registre, scope: 'activerecord.attributes.company')
    t_value = I18n.t(value, scope: [:boolean, :text])

    html = tag.span("#{label} : ", class: 'fr-text--bold')
    html << t_value
    html
  end
end
