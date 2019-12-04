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

  def index_antenne
    @needs_quo = current_user.antenne.needs_quo
    @needs_taking_care = current_user.antenne.needs_taking_care
    @needs_others_taking_care = current_user.antenne.needs_others_taking_care
  end

  def archives
    @needs_rejected = current_involved.needs_rejected
    @needs_done = current_involved.needs_done
    @needs_archived = current_involved.needs_archived
  end

  def archives_antenne
    @needs_rejected = current_user.antenne.needs_rejected
    @needs_done = current_user.antenne.needs_done
    @needs_archived = current_user.antenne.needs_archived
  end

  def show
    @diagnosis = retrieve_diagnosis
    authorize @diagnosis
    @current_roles = current_roles
    @highlighted_experts = highlighted_experts
  end

  def additional_experts
    @need = Need.find(params.require(:need))
    @query = params.require('query')&.strip

    @experts = Expert.omnisearch(@query)
      .where.not(id: @need.experts)
      .limit(15)
      .includes(:antenne, experts_subjects: :institution_subject)
  end

  def add_match
    @diagnosis = retrieve_diagnosis
    @current_roles = current_roles

    @need = Need.find(params.require(:need))
    expert_subject = ExpertSubject.find(params.require(:expert_subject))
    @match = Match.create(need: @need, expert: expert_subject.expert, subject: @need.subject)
    if @match.valid?
      ExpertMailer.delay.notify_company_needs(expert_subject.expert, @diagnosis)
    else
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
      []
    end
  end

  def retrieve_diagnosis
    Diagnosis.find(params.require(:id))
  end

  def mark_expert_viewed
    diagnosis = retrieve_diagnosis
    experts.each do |expert|
      UseCases::UpdateExpertViewedPageAt.perform(diagnosis: diagnosis, expert: expert)
    end
  end
end
