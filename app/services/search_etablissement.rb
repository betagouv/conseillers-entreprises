class SearchEtablissement
  # Recherche d'un établissement via l'appel à des API externes
  # Utilisable pour des champs en auto-complétion
  attr_accessor :query, :non_diffusables

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @query = params[:query]
    @non_diffusables = params[:non_diffusables]
  end

  def call
    if siret_search_type?
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
    siren = FormatSiret.siren_from_query(query)
    return if siren.blank?
    begin
      response = UseCases::SearchCompany.with_siren(siren, { non_diffusables: non_diffusables, url_keys: [:entreprises] })
      return [ApiEntreprise::SearchEtablissementWrapper.new(response)]
    rescue ApiEntreprise::ApiEntrepriseError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { error: message }
    end
  end

  def full_text_search
    response = ApiSirene::FullTextSearch.search(query)
    if response.success?
      return response.etablissements
    else
      error = response.error_message || I18n.t('companies.search.generic_error')
      return { error: error }
    end
  end
end
