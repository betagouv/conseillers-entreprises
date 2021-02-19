class SearchEtablissement
  # Recherche d'un établissement via l'appel à des API externes
  # Utilisable pour des champs en auto-complétion
  attr_accessor :query

  def self.call(query)
    self.new(query).call
  end

  def initialize(query)
    @query = query
  end

  def call
    if siret_search_type?
      # TODO : ne pas rechercher tant que pas chiffres siren suffisants
      siret_search
    else
      full_text_search
    end
  end

  private

  def siret_search_type?
    @query.gsub(/\s/, '').match(/^\d+$/)
  end

  def siret_search
    siren = FormatSiret.siren_from_query(@query)
    return if siren.blank?
    begin
      response = UseCases::SearchCompany.with_siren siren
      return [ApiEntreprise::SearchEtablissementWrapper.new(response)]
    rescue ApiEntreprise::ApiEntrepriseError => e
      p e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { error: message }
    end
  end

  def full_text_search
    response = SireneApi::FullTextSearch.search(@query)
    if response.success?
      return response.etablissements
    else
      error = response.error_message || I18n.t('companies.search.generic_error')
      return { error: error }
    end
  end
end
