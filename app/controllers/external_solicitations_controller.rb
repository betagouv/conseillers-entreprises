class ExternalSolicitationsController < PagesController
  layout 'external_solicitations'
  # Skip authentication token verification, we can't add authenticity token on session cookies in iframe
  skip_forgery_protection
  # Rails add X-Frame-Options same origine on headers, we must remove it to authorize external websites
  after_action :allow_iframe

  def new
    @landing = Landing.find_by(slug: params[:slug])
    @solicitation = Solicitation.new(landing: @landing, form_info: {
      institution_slug: params[:institution_slug], bg_color: "##{params[:bg_color]}",
        color: "##{params[:color]}", branding: "#{params[:logo]}"
    }, landing_options_slugs: [[params[:option]]], landing_slug: params[:slug])
  end

  def create
    @solicitation = Solicitation.create(solicitation_params)

    unless @solicitation.valid?
      flash.alert = @solicitation.errors.full_messages.to_sentence
      render 'flashes' and return
    end

    render :new
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, :landing_slug, :full_name,
              landing_options_slugs: [], form_info: {}, needs: {})
  end
end
