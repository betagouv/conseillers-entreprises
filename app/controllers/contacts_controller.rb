# frozen_string_literal: true

class ContactsController < ApplicationController
  def needs_historic
    @contact = Contact.find(params[:id])
    needs = Need.historic(@contact.email)
    @needs_in_progress = needs.in_progress
    @needs_done = needs.done
  end
end
