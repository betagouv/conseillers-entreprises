class Emails::SolicitationsController < ApplicationController
  before_action :find_solicitation
  before_action :authorize_index_solicitation

  def send_generic_email
    email_type = ActionController::Base.helpers.sanitize(params[:email_type])
    processor = CancelSolicitationWithEmail.new(@solicitation, email_type)
    if processor.valid?
      processor.cancel
      flash.notice = t('emails.sent')
    else
      flash.alert = t('emails.not_sent')
    end
    redirect_to solicitations_path(query: params[:query])
  end

  private

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end
end
