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
    return if @query.blank?
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
      entreprise_params = ApiEntreprise::Entreprise::Base.new(siren, { non_diffusables: non_diffusables }).call
      return [ApiConsumption::Models::FacilityAutocomplete.new(entreprise_params)]
    rescue ApiEntreprise::ApiEntrepriseError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { error: message }
    # I suspect there sometimes is another error uncatched. Capturing it for debugging purpose
    rescue => e
      Sentry.capture_exception(e)
      return { error: I18n.t('api_entreprise.default_error_message.etablissement') }
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
