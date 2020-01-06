# frozen_string_literal: true

class MatchesController < ApplicationController
  def update
    @match = retrieve_match
    @current_roles = current_roles
    previous_status = @match.status
    @match.update status: params[:status]
    UserMailer.update_match_notify(@match, current_user, previous_status).deliver_later
    if @match.status_taking_care?
      if @match.advisor.support_expert_subject.nil?
        CompanyMailer.taking_care_by_expert(@match).deliver_later
      else
        CompanyMailer.taking_care_by_support(@match).deliver_later
      end
    end
  end

  private

  def retrieve_match
    safe_params = params.permit(:id)
    match = Match.find(safe_params[:id])
    check_current_user_access_to(match)
    match
  end
end
