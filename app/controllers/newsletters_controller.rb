class NewslettersController < PagesController
  def new; end

  def create
    begin
      Mailjet::Contactslist_managecontact.create(id: ENV['MAILJET_NEWSLETTER_ID'], action: "addforce", email: params[:email])
      flash[:success] = t('.success_newsletter')
    rescue StandardError => e
      flash[:warning] = t('.error_mailjet')
    end
    redirect_back fallback_location: root_path
  end
end
