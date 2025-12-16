class ContactsController < ApplicationController
  def needs_historic
    @contact = authorize Contact.find(params[:id])
    email_needs = Need.for_emails(@contact.email)

    @needs_in_progress = policy_scope(email_needs.diagnosis_completed)
      .merge(Match.in_progress)
      .order(created_at: :desc)
    @needs_done = policy_scope(email_needs.diagnosis_completed)
      .merge(Match.done)
      .order(created_at: :desc)
  end
end
