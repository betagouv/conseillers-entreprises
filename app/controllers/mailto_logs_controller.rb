# frozen_string_literal: true

class MailtoLogsController < ApplicationController
  def create
    mailto = MailtoLog.create create_params
    render json: { success: mailto.present? }
  end

  private

  def create_params
    params.require(:mailto_log).permit(:question_id, :visit_id, :assistance_id)
  end
end
