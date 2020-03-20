# frozen_string_literal: true

class MatchesController < ApplicationController
  def update
    @match = Match.find(params[:id])
    authorize @match
    previous_status = @match.status
    @match.update status: params[:status]
    UserMailer.deduplicated_send_match_notify(@match, current_user, previous_status)
    if @match.status_taking_care?
      CompanyMailer.notify_taking_care(@match).deliver_later
    end
  end
end
