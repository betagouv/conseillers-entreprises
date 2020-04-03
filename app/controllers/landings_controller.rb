class LandingsController < PagesController
  before_action :save_form_info, only: %i[index show]
  before_action :retrieve_landing, only: %i[show create_solicitation]

  def index
    @landings = Rails.cache.fetch('landings', expires_in: 3.minutes) do
      Landing.ordered_for_home.to_a
    end
  end

  def show
    @solicitation = @landing.solicitations.new
  end

  def create_solicitation
    @solicitation = @landing.solicitations.create(solicitation_params.merge(retrieve_form_info))

    if @solicitation.persisted?
      CompanyMailer.confirmation_solicitation(@solicitation.email).deliver_later
      if ENV['FEATURE_SEND_ADMIN_SOLICITATION_EMAIL'].to_b
        AdminMailer.solicitation(@solicitation).deliver_later
      end
    end

    render :show # rerender the form on error, render the thankyou partial on success
  end

  private

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end

  def retrieve_form_info
    form_info = session.delete(:solicitation_form_info)
    { form_info: form_info }
  end

  def retrieve_landing
    slug = params[:slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end

    redirect_to root_path if @landing.nil?
  end

  def show_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :full_name, :phone_number, :email, form_info: {}, options: {})
  end
end
