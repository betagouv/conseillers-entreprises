class UtilitiesController < SharedController
  def search_etablissement
    results = SearchEtablissement.call(params.permit(:query).require(:query))
    respond_to do |format|
      format.json do
        render json: results.as_json
      end
    end
  end
end
