class SolicitationsController < ApplicationController
  skip_before_action :authenticate_user!

  include Alternatives

  def index
    alternative = current_alternative(alternatives)
    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params
      .merge({ alternative: alternative })
    render alternative
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

    reset_alternative
  end

  private

  def alternatives
    [:index_a, :index_b]
  end

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :phone_number, :email, form_info: {}, needs: {})
  end
end
