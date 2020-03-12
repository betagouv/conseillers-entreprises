# frozen_string_literal: true

class MatchesController < ApplicationController
  def update
    @match = Match.find(params[:id])
    authorize @match
    previous_status = @match.status
    @match.update status: params[:status]
    MatchMailerService.deduplicated_notify_status(@match, previous_status)
    if @match.status_taking_care?
      CompanyMailer.notify_taking_care(@match).deliver_later
    end
  end
end
