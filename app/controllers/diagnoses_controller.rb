# frozen_string_literal: true

class DiagnosesController < ApplicationController
  before_action :retrieve_diagnosis, only: %i[show archive unarchive]
  before_action :maybe_review_expert_subjects

  def index
    retrieve_diagnoses(current_user, false, :in_progress)
  end

  def processed
    retrieve_diagnoses(current_user, false, :completed)
    render :index
  end

  def new
    @current_solicitation = Solicitation.find_by(id: params[:solicitation])
    @diagnosis = DiagnosisCreation.new_diagnosis(@current_solicitation)
    @needs = Need.joins(diagnosis: :solicitation).where(diagnosis: { solicitations: { email: @current_solicitation&.email } })
  end

  def index_antenne
    retrieve_diagnoses(current_user.antenne, false)
  end

  def archives
    retrieve_diagnoses(current_user, true)
    render :index
  end

  def archives_antenne
    retrieve_diagnoses(current_user.antenne, true)
    render :index_antenne
  end

  def create
    @diagnosis = DiagnosisCreation.create_diagnosis(diagnosis_params.merge(advisor: current_user))

    if @diagnosis.persisted?
      redirect_to needs_diagnosis_path(@diagnosis)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @diagnosis
    if @diagnosis.step_completed?
      need = current_user.received_needs.where(diagnosis: @diagnosis).first || @diagnosis.needs.first
      redirect_to need_path(need)
    else
      redirect_to controller: 'diagnoses/steps', action: @diagnosis.step, id: @diagnosis
    end
  end

  def archive
    authorize @diagnosis, :update?
    @diagnosis.archive!
    redirect_to diagnoses_path
  end

  def unarchive
    authorize @diagnosis, :update?
    @diagnosis.unarchive!
    redirect_to diagnoses_path
  end

  private

  def retrieve_diagnosis
    @diagnosis = Diagnosis.find(params.require(:id))
  end

  def retrieve_diagnoses(scope, archived, status = :all)
    authorize Diagnosis, :index?
    @diagnoses = scope.sent_diagnoses.archived(archived)
      .distinct
      .left_outer_joins(:matches, needs: :matches)
      .includes(:matches, :visitee, facility: :company, needs: :matches)
      .send(status)
      .order(happened_on: :desc)
      .page(params[:page])
  end

  def diagnosis_params
    params.require(:diagnosis)
      .permit(:solicitation_id,
              facility_attributes: [
                :siret, :insee_code,
                company_attributes: :name
              ])
  end
end
