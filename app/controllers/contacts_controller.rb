class ContactsController < ApplicationController
  def needs_historic
    @contact = authorize Contact.find(params.expect(:id))
    email_needs = Need.for_emails(@contact.email)
    @needs_in_progress = email_needs
      .in_progress
      .order(created_at: :desc)
    @needs_done = email_needs
      .done
      .order(created_at: :desc)
  end
end
