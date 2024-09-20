# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date) rescue nil
  end

  def annee_effectif(annee)
    return nil if annee.nil?
    "(#{annee})"
  end

  def translated_nature_activites(natures)
    return nil unless natures.any?
    natures.map{ |nature| translated_nature_activite(nature) }
  end

  def translated_nature_activite(nature)
    I18n.t(nature, scope: 'natures_entreprise')
  end
end
