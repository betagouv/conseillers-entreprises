# frozen_string_literal: true

class NeedsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: -> { params[:access_token].present? }
  before_action :authenticate_expert!, if: -> { params[:access_token].present? }

  after_action :mark_expert_viewed, only: :show

  def index
    @needs_quo = current_involved.needs_quo
    @needs_taking_care = current_involved.needs_taking_care
    @needs_others_taking_care = current_involved.needs_others_taking_care
  end

  def archives
    @needs_rejected = current_involved.needs_rejected
    @needs_done = current_involved.needs_done
    @needs_archived = current_involved.needs_archived
  end

  def show
    @diagnosis = retrieve_diagnosis
    @current_roles = current_roles
    @highlighted_experts = highlighted_experts
  end

  private

  def experts
    current_user.present? ? current_user.experts.order(:full_name)
      : [current_expert]
  end

  def current_involved
    current_user || current_expert
  end

  def highlighted_experts
    safe_params = params.permit(:highlighted_expert)
    if safe_params[:highlighted_expert].present?
      [Expert.find(safe_params[:highlighted_expert])]
    else
      current_roles
    end
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
