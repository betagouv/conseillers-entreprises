# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = current_user.sent_diagnoses.only_active.order(created_at: :desc)
      .distinct
      .left_outer_joins(:matches,
        diagnosed_needs: :matches)
      .includes(:matches,
        :visitee, facility: :company,
        diagnosed_needs: :matches)
  end

  def show
    diagnosis = Diagnosis.only_active.find(params[:id])
    check_current_user_access_to(diagnosis)
    redirect_to action: "step#{diagnosis.step}", id: diagnosis
  end

  def destroy
    diagnosis = Diagnosis.find params[:id]
    check_current_user_access_to(diagnosis)
    diagnosis.archive!
    redirect_to diagnoses_path
  end

  def step2
    @diagnosis = diagnosis_in_progress(params[:id])
    @categories = Category.all.includes(:questions)
  end

  def besoins
    @diagnosis = diagnosis_in_progress(params[:id])
    diagnosis_params = params.require(:diagnosis).permit(:content,
      diagnosed_needs_attributes: [:_destroy, :content, :question_id, :id])
    diagnosis_params[:step] = 3
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step3, id: @diagnosis
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      @categories = Category.all.includes(:questions)
      render action: :step2
    end
  end

  def step3
    @diagnosis = diagnosis_in_progress(params[:id])
  end

  def visite
    @diagnosis = diagnosis_in_progress(params[:id])
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
    @diagnosis = diagnosis_in_progress(params[:id])
    @diagnosed_needs = UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts.of_diagnosis(@diagnosis)
    relays = @diagnosis.facility.commune.relays
    @relay_users = User.where(relays: relays)
      .order(:contact_page_order, :full_name)
  end

  def selection
    diagnosis = diagnosis_in_progress(params[:id])
    experts = params[:matches]
    if experts.present?
      UseCases::SaveAndNotifyDiagnosis.perform diagnosis, params[:matches]
      diagnosis.update step: Diagnosis::LAST_STEP
      flash.notice = I18n.t('diagnoses.step5.notifications_sent')
      redirect_to action: :step5, id: diagnosis
    end
  end

  def step5
    associations = [:visitee, facility: [:company], diagnosed_needs: [:matches]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_current_user_access_to(@diagnosis)
  end

  private

  def params_for_visite
    permitted = params.require(:diagnosis).permit(:happened_on, visitee_attributes: [:full_name, :role, :email, :phone_number, :id])
    permitted.require(:happened_on)
    permitted.require(:visitee_attributes).require(:full_name)
    permitted.require(:visitee_attributes).require(:role)
    permitted.require(:visitee_attributes).require(:email)
    permitted.require(:visitee_attributes).require(:phone_number)
    puts "permitted #{permitted}"
    permitted
  end

  def diagnosis_in_progress(diagnosis_id)
    diagnosis = Diagnosis.only_active.find(diagnosis_id)
    check_current_user_access_to(diagnosis)

    if diagnosis.step == Diagnosis::LAST_STEP
      not_found
    end

    diagnosis
  end
end
