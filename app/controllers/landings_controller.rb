class LandingsController < PagesController
  before_action :save_form_info, only: %i[index show]
  before_action :retrieve_landing, except: %i[index subscribe_newsletter]

  def index
    @landings = Rails.cache.fetch('landings', expires_in: 3.minutes) do
      Landing.ordered_for_home.to_a
    end
  end

  def show; end

  def new_solicitation
    @solicitation = @landing.solicitations.new(landing_options_slugs: [params[:option_slug]].compact)
  end

  def create_solicitation
    @solicitation = Solicitation.create(solicitation_params.merge(retrieve_form_info))
    if @solicitation.persisted?
      CompanyMailer.confirmation_solicitation(@solicitation.email).deliver_later
      if ENV['FEATURE_SEND_ADMIN_SOLICITATION_EMAIL'].to_b
        AdminMailer.solicitation(@solicitation).deliver_later
      end
    end

    render :new_solicitation # rerender the form on error, render the thankyou partial on success
  end

  def subscribe_newsletter
    begin
      Mailjet::Contactslist_managecontact.create(id: ENV['MAILJET_NEWSLETTER_ID'], action: "addforce", email: params[:email])
      flash[:success] = t('.success_newsletter')
    rescue StandardError => e
      flash[:warning] = t('.error_mailjet')
    end
    redirect_back fallback_location: root_path
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
      .permit(:description, :siret, :full_name, :phone_number, :email, :landing_slug, landing_options_slugs: [])
  end
end
