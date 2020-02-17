# frozen_string_literal: true

class MatchesController < ApplicationController
  def update
    @match = Match.find(params[:id])
    authorize @match
    previous_status = @match.status
    @match.update status: params[:status]
    UserMailer.deduplicated_send_match_notify(@match, current_user, previous_status)
    if @match.status_taking_care?
      UserMailer.notify_other_experts(match, user).deliver_later
      if @match.advisor.support_expert_subject.nil?
        CompanyMailer.taking_care_by_expert(@match).deliver_later
      else
        CompanyMailer.taking_care_by_support(@match).deliver_later
      end
    end
  end
end
