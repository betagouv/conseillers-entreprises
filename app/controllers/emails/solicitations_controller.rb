class Emails::SolicitationsController < ApplicationController
  before_action :find_solicitation
  before_action :authorize_index_solicitation

  def send_generic_email
    email_type = ActionController::Base.helpers.sanitize(params[:email_type])
    processor = SendSolicitationGenericEmail.new(@solicitation, email_type)
    if processor.valid?
      processor.send_email
      flash.notice = t('emails.sent')
      render_turbo_stream_or_html
    else
      flash.alert = t('emails.not_sent')
      render_turbo_stream_or_html(status: :unprocessable_content)
    end
  end

  private

  def render_turbo_stream_or_html(status: :ok)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@solicitation),
          turbo_stream.append('flash', partial: 'shared/flashes', locals: { flash: flash })
        ], status: status, layout: false
      end
      format.html { redirect_to conseiller_solicitations_path(query: params[:query]) }
    end
  end

  def authorize_index_solicitation
    authorize Solicitation, :index?
  end

  def find_solicitation
    @solicitation = Solicitation.find(params[:id])
  end
end
