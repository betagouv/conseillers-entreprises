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

  def add_more_matches
    @diagnosis = retrieve_diagnosis
    @current_roles = current_roles
    @highlighted_experts = highlighted_experts

    @need = Need.find(params.require(:need_id))
    expert_skill = ExpertSkill.find(params.require(:expert_skill_id))
    @match = Match.create(need: @need, expert: expert_skill.expert, skill: expert_skill.skill)
    if @match.invalid?
      flash.alert = @match.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
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
    begin
      [Expert.find(params.require(:highlighted_expert))]
    rescue
      current_roles
    end
  end

  def retrieve_diagnosis
    diagnosis = Diagnosis.find(params.require(:id))
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
