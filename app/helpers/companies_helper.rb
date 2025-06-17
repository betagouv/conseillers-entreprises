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
    return [] unless natures.any?
    natures.filter_map{ |nature| translated_nature_activite(nature) }
  end

  def translated_nature_activite(nature)
    return nil if nature.nil?
    I18n.t(nature, scope: 'natures_entreprise', default: nature.humanize)
  end

  def naf_a10_collection
    I18n.t('naf_libelle_a10').map{ |n| [n.last, n.first] }
  end
end
