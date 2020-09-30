# frozen_string_literal: true

class NeedsController < ApplicationController
  before_action :maybe_review_expert_subjects
  before_action :retrieve_variables_for_index, only: %i[index taking_care]
  before_action :retrieve_need, only: %i[archive unarchive]

  def index
    @needs = current_user.needs_quo.or(current_user.needs_others_taking_care).page params[:page]
    @count_needs = Rails.cache.fetch([current_user.received_needs]) do
      {
        quo: @needs.size,
        taking_care: current_user.needs_taking_care.size
      }
    end
  end

  def taking_care
    retrieve_needs(current_user, :needs_taking_care)
    @count_needs = Rails.cache.fetch([current_user.received_needs]) do
      {
        quo: current_user.needs_quo.or(current_user.needs_others_taking_care).size,
        taking_care: @needs.size
      }
    end
    render :index
  end

  def index_antenne
    @needs = current_user.antenne.needs_quo.or(current_user.antenne.needs_others_taking_care).page params[:page]
  end

  def taking_care_antenne
    retrieve_needs(current_user.antenne, :needs_taking_care)
    render :index_antenne
  end

  def archives
    retrieve_needs(current_user, :needs_done)
  end

  def archives_rejected
    retrieve_needs(current_user, :needs_rejected)
    render :archives
  end

  def archives_failed
    retrieve_needs(current_user, :needs_archived)
    render :archives
  end

  def archives_antenne
    retrieve_needs(current_user.antenne, :needs_done)
  end

  def archives_antenne_rejected
    retrieve_needs(current_user.antenne, :needs_rejected)
    render :archives_antenne
  end

  def archives_antenne_failed
    retrieve_needs(current_user.antenne, :needs_archived)
    render :archives_antenne
  end

  def show
    @diagnosis = retrieve_diagnosis
    authorize @diagnosis
    unless @diagnosis.step_completed?
      # let diagnoses_controller (and steps_controller) handle incomplete diagnoses
      redirect_to @diagnosis and return
    end

    @highlighted_experts = highlighted_experts
  end

  def additional_experts
    @need = Need.find(params.require(:need))
    @query = params.require('query')&.strip

    @experts = Expert.omnisearch(@query)
      .with_subjects
      .where.not(id: @need.experts)
      .limit(15)
      .includes(:antenne, experts_subjects: :institution_subject)
  end

  def add_match
    @diagnosis = retrieve_diagnosis

    @need = Need.find(params.require(:need))
    expert_subject = ExpertSubject.find(params.require(:expert_subject))
    expert = expert_subject.expert
    @match = Match.create(need: @need, expert: expert, subject: @need.subject)
    if @match.valid?
      ExpertMailer.notify_company_needs(expert, @diagnosis).deliver_later
      expert.first_notification_help_email
    else
      flash.alert = @match.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def archive
    authorize @need, :archive?
    @need.archive!
    flash[:notice] = t('.subjet_achived')
    redirect_to need_path(@need.diagnosis)
  end

  def unarchive
    authorize @need, :archive?
    @need.update(archived_at: nil)
    flash[:notice] = t('.subject_unarchived')
    redirect_to need_path(@need.diagnosis)
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

  def retrieve_need
    @need = Need.find(params.require(:id))
  end

  def retrieve_variables_for_index
    @experts_emails = current_user.experts.distinct.pluck(:email)
    @no_needs = current_user.needs_taking_care.empty? &&
        current_user.needs_others_taking_care.empty? &&
        current_user.needs_quo.empty?
  end

  def retrieve_needs(scope, status)
    @needs = scope.send(status).page params[:page]
  end
end
