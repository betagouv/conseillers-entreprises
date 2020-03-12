class LandingsController < PagesController
  def index
    @landings = Rails.cache.fetch('landings', expires_in: 1.hour) do
      Landing.ordered_for_home.to_a
    end
    @tracking_params = info_params.except(:slug)
  end

  def show
    @landing = retrieve_landing
    if @landing.nil?
      redirect_to root_path
      return
    end

    @landing_topics = Rails.cache.fetch("landing_topics-#{@landing.id}", expires_in: 1.hour) do
      @landing.landing_topics.ordered_for_landing.to_a
    end

    @tracking_params = info_params.except(:slug)
    @solicitation = Solicitation.new
    @solicitation.form_info = info_params
  end

  def solicitation
    @solicitation = Solicitation.create(solicitation_params)

    if !@solicitation.valid?
      @result = 'failure'
      @partial = 'form'
      flash.alert = @solicitation.errors.full_messages.to_sentence
      return
    end

    @result = 'success'
    @partial = 'thank_you'
    CompanyMailer.confirmation_solicitation(@solicitation.email).deliver_later
    AdminMailer.solicitation(@solicitation).deliver_later

    respond_to do |format|
      format.html { redirect_to landing_path(@solicitation.slug, anchor: 'section-formulaire'), notice: t('.thanks') }
      format.js
    end
  end

  private

  def retrieve_landing
    slug = params[:slug]&.to_sym
    Rails.cache.fetch("landing-#{slug}", expires_in: 1.hour) do
      Landing.find_by(slug: slug)
    end
  end

  def info_params
    params.permit(*Solicitation::FORM_INFO_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, form_info: {}, needs: {})
  end
end
