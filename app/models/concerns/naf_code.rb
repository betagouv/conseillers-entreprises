module NafCode
  # https://www.insee.fr/fr/information/2028155
  #
  extend ActiveSupport::Concern

  def self.naf_libelle(naf_code, level = 'a10')
    return I18n.t('no_data') if naf_code.nil?
    I18n.t(naf_code, scope: "naf_libelle_#{level}", default: 'code non trouvé')
  end

  def self.code_a10(naf_code)
    return if naf_code.nil?
    I18n.t(level2_code(naf_code), scope: 'naf_level2_to_naf_a10', default: 'code non trouvé')
  end

  def self.level2_code(naf_code)
    return if naf_code.nil?
    naf_code[0..1]
  end
end
