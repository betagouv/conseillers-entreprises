# frozen_string_literal: true

class ContactController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def create
    message = CompanyMessage.new(contact_params)
    if message.valid?
      @partial = 'thank_you'
      AdminMailer.delay.company_message(message)
    else
      @partial = 'form'
      flash.alert = message.errors.full_messages.to_sentence
    end
  end

  private

  def contact_params
    # params.require(:contact).permit(:description, :phone_number, :email, :besoins)
    params.require(:contact).permit(:description, :phone_number, :email, besoins: {})
  end
end
