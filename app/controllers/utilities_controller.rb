class UtilitiesController < SharedController
  def search_etablissement
    results = SearchEtablissement.call(search_etablissement_params)
    respond_to do |format|
      format.json do
        render json: results.as_json
      end
    end
  end

  private

  def search_etablissement_params
    params.permit(:query, :non_diffusables)
  end
end
