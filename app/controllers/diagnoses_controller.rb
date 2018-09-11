# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = current_user.diagnoses.only_active.reverse_chronological
      .distinct
      .left_outer_joins(:matches,
        diagnosed_needs: :matches)
      .includes(:matches,
        diagnosed_needs: :matches,
        visit: [:visitee, facility: :company])
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
    diagnosis_params[:visit_attributes][:visitee_attributes][:company_id] = @diagnosis.visit.facility.company.id
    diagnosis_params[:step] = 4
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step4, id: @diagnosis
    else
      flash.alert = @diagnosis.visit.errors.full_messages.to_sentence
      render action: :step3
    end
  end

  def step4
    @diagnosis = diagnosis_in_progress(params[:id])
    @diagnosed_needs = UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts.of_diagnosis(@diagnosis)
    @relays_full_names = Relay.of_diagnosis_location(@diagnosis).map(&:user).map(&:full_name)
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
    associations = [visit: [:visitee, facility: [:company]], diagnosed_needs: [:matches]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_current_user_access_to(@diagnosis)
  end

  private

  def params_for_visite
    permitted = params.require(:diagnosis).permit(visit_attributes: {})
    visit_params = permitted.require(:visit_attributes)
    [:id, :happened_on].each{ |key| visit_params.require(key) }
    visitee_params = visit_params.require(:visitee_attributes)
    [:id, :full_name, :role, :email, :phone_number].each{ |key| visitee_params.require(key) }
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
