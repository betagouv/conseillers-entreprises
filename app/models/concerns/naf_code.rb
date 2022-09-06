module NafCode
  # https://www.insee.fr/fr/information/2028155
  #
  extend ActiveSupport::Concern

  def libelle_a10
    NafCode::naf_libelle(self.libelle_a10)
  end

  def self.naf_libelle(level = 'a10', naf_code)
    return I18n.t('no_data') if naf_code.nil?
    I18n.t(naf_code, scope: "naf_libelle_#{level}")
  end

  def self.libelle_a10(naf_code_a10)
    return I18n.t('no_data') if naf_code_a10.nil?
    I18n.t(naf_code_a10, scope: 'naf_libelle_a10')
  end

  def self.code_a10(naf_code)
    return if naf_code.nil?
    I18n.t(level2_code(naf_code), scope: 'naf_level2_to_naf_a10')
  end

  def self.level2_code(naf_code)
    return if naf_code.nil?
    naf_code[0..1]
  end
end
