module NafCode
  # https://www.insee.fr/fr/information/2028155
  #
  extend ActiveSupport::Concern

  def self.naf_libelle(naf_code, level = 'a10')
    return I18n.t('no_data') if naf_code.blank?
    I18n.t(naf_code, scope: "naf_libelle_#{level}", default: I18n.t('naf_libelle.code_not_found'))
  end

  def self.code_a10(naf_code)
    return if naf_code.blank?
    I18n.t(level2_code(naf_code), scope: 'naf_level2_to_naf_a10', default: I18n.t('naf_libelle.code_not_found'))
  end

  def self.level2_code(naf_code)
    return if naf_code.blank?
    naf_code[0..1]
  end

  def self.nafa_libelle(nafa_code)
    return nil if nafa_code.blank?
    nafa_code = nafa_code.gsub(/[^A-Za-z0-9]/, '')
    I18n.t(nafa_code, scope: "nafa_code_to_libelle", default: I18n.t('naf_libelle.code_not_found'))
  end
end
