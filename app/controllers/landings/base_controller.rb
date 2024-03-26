class Landings::BaseController < PagesController
  include IframePrefix

  private

  def save_query_params
    p "save_query_params---------------------"
    p query_params
    p 'sesssssssssssssion'
    p session[:solicitation_form_info]
    session[:solicitation_form_info] = query_params if query_params.present?
    p session[:solicitation_form_info]
    p "save_query_params END---------------------"
  end
end
