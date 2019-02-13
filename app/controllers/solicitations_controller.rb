class SolicitationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @solicitation = Solicitation.new
  end

  def create
    @solicitation = Solicitation.new(solicitation_params)

    if !@solicitation.valid?
      @result = 'failure'
      @partial = 'form'
      flash.alert = @solicitation.errors.full_messages.to_sentence
      return
    end

    @result = 'success'
    @partial = 'thank_you'
    AdminMailer.delay.solicitation(@solicitation)
  end

  private

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :phone_number, :email, needs: {})
  end
end
