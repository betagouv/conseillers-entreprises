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
    @params = {}
    @solicitation = Solicitation.find_by(id: params[:solicitation])
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

  def create_diagnosis_without_siret
    insee_code = params[:insee_code]
    facility = Facility.new(company: Company.new(name: params[:name]))
    city_params = ApiAdresse::Query.city_with_code(insee_code)
    facility.readable_locality = "#{city_params['codesPostaux']&.first} #{city_params['nom']}"
    facility.commune = Commune.find_or_initialize_by(insee_code: insee_code)

    diagnosis = Diagnosis.new(advisor: current_user, facility: facility, step: :needs)
    if params[:solicitation].present?
      solicitation = Solicitation.find_by(id: params[:solicitation])
      diagnosis.solicitation = solicitation
    end

    if diagnosis.save
      redirect_to needs_diagnosis_path(diagnosis)
    else
      render body: nil, status: :bad_request
    end
  end

  def show
    authorize @diagnosis
    if @diagnosis.step_completed?
      redirect_to need_path(@diagnosis)
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
end
