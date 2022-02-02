class Emails::SolicitationsController < ApplicationController
  before_action :find_solicitation
  before_action :authorize_index_solicitation

  def bad_quality_difficulties
    send_email(:bad_quality_difficulties)
  end

  def bad_quality_investment
    send_email(:bad_quality_investment)
  end

  def out_of_region
    send_email(:out_of_region)
  end

  def employee_labor_law
    send_email(:employee_labor_law)
  end

  def particular_retirement
    send_email(:particular_retirement)
  end

  def creation
    send_email(:creation)
  end

  def siret
    send_email(:siret)
  end

  def moderation
    send_email(:moderation)
  end

  private

  def send_email(email_name)
    SolicitationMailer.send(email_name, @solicitation).deliver_later
    flash.notice = t('emails.sent')
    redirect_to solicitations_path
  end

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end
end
