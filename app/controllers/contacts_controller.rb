# frozen_string_literal: true

class ContactsController < ApplicationController
  def needs_historic
    @contact = Contact.find(params[:id])
    needs = Need.for_emails_and_sirets([@contact.email])
    @needs_in_progress = NeedInProgressPolicy::Scope.new(current_user, needs.in_progress).resolve
    @needs_done = NeedDonePolicy::Scope.new(current_user, needs.done).resolve
  end
end
