# frozen_string_literal: true

class NeedsController < ApplicationController
  def index
    @experts_emails = current_user.experts.distinct.pluck(:email)
    @needs_quo = current_user.needs_quo
    @needs_taking_care = current_user.needs_taking_care
    @needs_others_taking_care = current_user.needs_others_taking_care
  end

  def index_antenne
    @needs_quo = current_user.antenne.needs_quo
    @needs_taking_care = current_user.antenne.needs_taking_care
    @needs_others_taking_care = current_user.antenne.needs_others_taking_care
  end

  def archives
    @needs_rejected = current_user.needs_rejected
    @needs_done = current_user.needs_done
    @needs_archived = current_user.needs_archived
  end

  def archives_antenne
    @needs_rejected = current_user.antenne.needs_rejected
    @needs_done = current_user.antenne.needs_done
    @needs_archived = current_user.antenne.needs_archived
  end

  def show
    @diagnosis = retrieve_diagnosis
    authorize @diagnosis
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

    @need = Need.find(params.require(:need))
    expert_subject = ExpertSubject.find(params.require(:expert_subject))
    @match = Match.create(need: @need, expert: expert_subject.expert, subject: @need.subject)
    if @match.valid?
      ExpertMailer.notify_company_needs(expert_subject.expert, @diagnosis).deliver_later
    else
      flash.alert = @match.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  private

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
end
