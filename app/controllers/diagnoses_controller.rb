# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = sent_diagnoses(archived: false)
  end

  def archives
    @diagnoses = sent_diagnoses(archived: true)
  end

  def show
    diagnosis = safe_diagnosis_param
    if diagnosis.completed?
      redirect_to besoin_path(diagnosis)
    else
      redirect_to action: "step#{diagnosis.step}", id: diagnosis
    end
  end

  def archive
    diagnosis = safe_diagnosis_param
    diagnosis.archive!
    redirect_to diagnoses_path
  end

  def step2
    @diagnosis = safe_diagnosis_param
    @themes = Theme.ordered_for_interview
  end

  def besoins
    @diagnosis = safe_diagnosis_param
    diagnosis_params = params.require(:diagnosis).permit(:content,
      needs_attributes: [:_destroy, :content, :subject_id, :id])
    diagnosis_params[:step] = 3
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step3, id: @diagnosis
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      @themes = Theme.all.includes(:subjects)
      render action: :step2
    end
  end

  def step3
    @diagnosis = safe_diagnosis_param
  end

  def visite
    @diagnosis = safe_diagnosis_param
    diagnosis_params = params_for_visite
    diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
    diagnosis_params[:step] = 4
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step4, id: @diagnosis
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render action: :step3
    end
  end

  def step4
    @diagnosis = safe_diagnosis_param
  end

  def selection
    @diagnosis = safe_diagnosis_param
    if @diagnosis.match_and_notify!(params_for_matches)
      flash.notice = I18n.t('diagnoses.step5.notifications_sent')
      redirect_to besoin_path(@diagnosis)
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render action: :step4, status: :bad_request
    end
  end

  private

  def sent_diagnoses(archived:)
    current_user.sent_diagnoses.archived(archived).order(created_at: :desc)
      .distinct
      .left_outer_joins(:matches,
        needs: :matches)
      .includes(:matches,
        :visitee, facility: :company,
        needs: :matches)
  end

  def params_for_visite
    permitted = params.require(:diagnosis).permit(:happened_on, visitee_attributes: [:full_name, :role, :email, :phone_number, :id])
    permitted.require(:happened_on)
    permitted.require(:visitee_attributes).require(:full_name)
    permitted.require(:visitee_attributes).require(:role)
    permitted.require(:visitee_attributes).require(:email)
    permitted.require(:visitee_attributes).require(:phone_number)
    permitted
  end

  def params_for_matches
    matches = params.permit(matches: {}).require(:matches)
    experts_skills_for_needs = matches.transform_values do |expert_skills_selection|
      expert_skills_selection.select{ |_,v| v == '1' }.keys
    end
    experts_skills_for_needs
  end

  def safe_diagnosis_param
    safe_params = params.permit(:id)
    diagnosis = Diagnosis.find(safe_params[:id])
    check_current_user_access_to(diagnosis)
    diagnosis
  end
end
