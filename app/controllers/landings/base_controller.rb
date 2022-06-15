class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    saved_params = session[:solicitation_form_info] || {}
    # siret : peut être transmis via l'url (iframe)
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS + [:siret] + AdditionalSubjectQuestion.pluck(:key))
    saved_params.merge!(query_params)
    session[:solicitation_form_info] = saved_params if saved_params.present?
  end

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS, AdditionalSubjectQuestion.pluck(:key))
  end
end
