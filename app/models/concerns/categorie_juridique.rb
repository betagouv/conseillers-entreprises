module CategorieJuridique
  # https://www.insee.fr/fr/information/2028129
  #
  extend ActiveSupport::Concern

  def categorie_juridique
    CategorieJuridique.description(self.legal_form_code)
  end

  def self.description(legal_form_code, niveau = 3)
    return I18n.t('other') if legal_form_code.blank?

    case niveau
    when 1
      legal_form_code = legal_form_code.first(1)
    when 2
      legal_form_code = legal_form_code.first(2)
    when 3
      legal_form_code = legal_form_code.first(4)
    end

    scope = "categories_juridiques.niveau#{niveau}"
    I18n.t(legal_form_code, scope: scope, default: I18n.t('other'))
  end

  ENTREPRENEUR_INDIVIDUEL = '1000'
end
