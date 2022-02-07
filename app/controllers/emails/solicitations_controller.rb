class Emails::SolicitationsController < ApplicationController
  before_action :find_solicitation
  before_action :authorize_index_solicitation

  def send_generic_email
    email_type = ActionController::Base.helpers.sanitize(params[:email_type])
    if email_type.present? && @solicitation.present?
      SolicitationMailer.send(email_type, @solicitation).deliver_later
      flash.notice = t('emails.sent')
    else
      flash.alert = t('emails.not_sent')
    end
    redirect_to solicitations_path
  end

  private

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end
end
