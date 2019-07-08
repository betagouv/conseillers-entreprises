# frozen_string_literal: true

class NeedsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  after_action :mark_expert_viewed, only: :show

  def index
    @needs_taking_care = received_needs
      .where(matches: received_matches.status_taking_care)
      .archived(false)

    @needs_quo = received_needs
      .by_status(:quo)
      .where.not(matches: received_matches.status_not_for_me)
      .archived(false)

    @needs_others_taking_care = received_needs
      .by_status(:taking_care)
      .where.not(matches: received_matches.status_taking_care)
      .archived(false)
  end

  def archives
    @needs_rejected = received_needs
      .where(matches: received_matches.status_not_for_me)
      .archived(false)

    @needs_done = received_needs
      .by_status(:done)
      .archived(false)

    @needs_archived = received_needs
      .archived(true)
  end

  def show
    @diagnosis = retrieve_diagnosis
    @current_roles = current_roles
  end

  private

  def experts
    current_user.present? ? current_user.experts.order(:full_name)
      : [current_expert]
  end

  def received_needs
    current_user.present? ? current_user.received_needs : current_expert.received_needs
  end

  def received_matches
    current_user.present? ? current_user.received_matches : current_expert.received_matches
  end

  def retrieve_diagnosis
    safe_params = params.permit(:id)
    diagnosis = Diagnosis.find(safe_params[:id])
    check_current_user_access_to(diagnosis, :read)
    diagnosis
  end

  def mark_expert_viewed
    diagnosis = retrieve_diagnosis
    experts.each do |expert|
      UseCases::UpdateExpertViewedPageAt.perform(diagnosis: diagnosis, expert: expert)
    end
  end
end
