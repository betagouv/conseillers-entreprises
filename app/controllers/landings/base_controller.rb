class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    session[:solicitation_form_info] = set_solicitation_form_info(session[:solicitation_form_info], query_params)
  end

  def set_solicitation_form_info(solicitation_form_info, query_params)
    return if query_params.nil?
    solicitation_form_info ||= {}
    # on supprime les éventuelles campagnes en session pour ne garder que la dernière
    keys_to_delete = [:pk_campaign, :mtm_campaign, :pk_kwd, :mtm_kwd]
    solicitation_form_info.except!(*keys_to_delete)
    solicitation_form_info.merge(query_params)
  end
end
