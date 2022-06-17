class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    session[:solicitation_form_info] = query_params if query_params.present?
  end

  def query_params
    saved_params = session[:solicitation_form_info] || {}
    # pas de session dans les iframe, on recupere les params dans l'url
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS + [:siret] + AdditionalSubjectQuestion.pluck(:key))
    query_params.merge!(saved_params)
  end
  helper_method :query_params

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS, AdditionalSubjectQuestion.pluck(:key))
  end
end
