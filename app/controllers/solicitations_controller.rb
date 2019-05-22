class SolicitationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @featured_landings = Landing.featured.ordered_for_home
    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params
  end

  def create
    @solicitation = Solicitation.create(solicitation_params)

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

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :phone_number, :email, form_info: {}, needs: {})
  end
end
