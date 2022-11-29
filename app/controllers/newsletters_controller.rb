class NewslettersController < PagesController
  def new; end

  def create
    api_instance = SibApiV3Sdk::ContactsApi.new
    contact_params = {
      email: params[:email],
      listIds: [ENV['SENDINBLUE_NEWSLETTER_ID'].to_i],
      updateEnabled: true
    }

    begin
      api_instance.create_contact(SibApiV3Sdk::CreateContact.new(contact_params))
      flash[:notice] = t('.success_newsletter_html')
    rescue SibApiV3Sdk::ApiError => e
      Sentry.capture_exception(e)
      flash[:alert] = t('.error_newsletter_subscription')
    end

    redirect_back fallback_location: root_path
  end

  def unsubscribe; end
end
