class CategorieJuridique
  # https://www.insee.fr/fr/information/2028129
  #
  def self.description(legal_form_code, niveau = 1)
    return I18n.t('other') if legal_form_code.blank?

    case niveau
    when 1
      legal_form_code = legal_form_code.first(1)
    when 2
      legal_form_code = legal_form_code.first(2)
    when 3
      legal_form_code = legal_form_code.first(4)
    end

    I18n.t("categories_juridiques.niveau#{niveau}.#{legal_form_code}", default: I18n.t('other'))
  end
end
