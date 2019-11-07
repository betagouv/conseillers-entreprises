class SolicitationsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @solicitation = Solicitation.create(solicitation_params)

    if !@solicitation.valid?
      @result = 'failure'
      @partial = 'solicitations/form'
      flash.alert = @solicitation.errors.full_messages.to_sentence
      return
    end

    @result = 'success'
    @partial = 'solicitations/thank_you'
    AdminMailer.delay.solicitation(@solicitation)
  end

  private

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, form_info: {}, needs: {})
  end
end
