class LandingsController < PagesController
  before_action :save_form_info, only: %i[index show]
  before_action :retrieve_landing, except: %i[index]

  include IframePrefix

  def index
    @landings = Rails.cache.fetch('landings', expires_in: 3.minutes) do
      Landing.ordered_for_home.to_a
    end
    @landing_emphasis = Landing.emphasis
  end

  def show; end

  def new_solicitation
    @solicitation = @landing.solicitations.new(landing_options_slugs: [params[:option_slug]].compact)
  end

  def create_solicitation
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_form_info)
    @solicitation = SolicitationModification::Create.call(sanitized_params)
    if @solicitation.persisted?
      CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
      @solicitation.delay.prepare_diagnosis(nil)
    end

    render :new_solicitation # rerender the form on error, render the thankyou partial on success
  end

  private

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end

  def retrieve_form_info
    # Les params ne passent pas en session dans les iframe, raison pour laquelle on check ici aussi les params de l'url
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session.delete(:solicitation_form_info)
    { form_info: form_info }
  end

  def retrieve_landing
    slug = params[:slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end

  def show_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_slug, :description, :code_region,
              *Solicitation::FIELD_TYPES.keys,
              landing_options_slugs: [])
  end
end
