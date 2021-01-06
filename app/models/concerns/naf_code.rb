module NafCode
  # https://www.insee.fr/fr/information/2028155
  #
  extend ActiveSupport::Concern

  def libelle_a10
    NafCode::libelle_a10(self.libelle_a10)
  end

  def self.libelle_a10(naf_code_a10)
    return I18n.t('no_data') if naf_code_a10.nil?
    I18n.t(naf_code_a10, scope: 'libelle_naf_a10')
  end

  def self.code_a10(naf_code)
    return if naf_code.nil?
    I18n.t(naf_code[0..1], scope: 'naf_level2_to_naf_a10')
  end
end
