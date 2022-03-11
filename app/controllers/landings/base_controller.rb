class Landings::BaseController < PagesController
  include IframePrefix

  before_action :retrieve_landing, except: [:home]

  private

  def retrieve_landing
    landing_slug = params.require(:landing_slug)
    @landing = Rails.cache.fetch("landing-#{landing_slug}", expires_in: 1.minute) do
      Landing.not_archived.find_by(slug: landing_slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end

  def save_query_params
    saved_params = session[:solicitation_form_info] || {}
    # siret : peut être transmis via l'url (iframe)
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS + [:siret])
    saved_params.merge!(query_params)
    session[:solicitation_form_info] = saved_params if saved_params.present?
  end

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS)
  end
end
