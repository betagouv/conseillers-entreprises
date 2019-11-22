# frozen_string_literal: true

class MatchesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  def update
    @match = retrieve_match
    @current_roles = current_roles
    @match.update status: params[:status]
  end

  private

  def retrieve_match
    safe_params = params.permit(:id)
    match = Match.find(safe_params[:id])
    check_current_user_access_to(match)
    match
  end
end
