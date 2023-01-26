class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    session[:solicitation_form_info] = query_params[:solicitation_form_info] if query_params.present?
  end
end
