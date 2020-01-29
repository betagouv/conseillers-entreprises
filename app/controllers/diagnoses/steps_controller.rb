class Diagnoses::StepsController < ApplicationController
  before_action :retrieve_diagnosis

  def besoins
    if request.post?
      authorize @diagnosis, :update?

      diagnosis_params = params.require(:diagnosis).permit(:content,
                                                           needs_attributes: [:_destroy, :content, :subject_id, :id])
      diagnosis_params[:step] = 3
      if @diagnosis.update(diagnosis_params)
        redirect_to action: :visite, id: @diagnosis and return
      end
      flash.alert = @diagnosis.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.js { render 'flashes' }
      format.html do
        @themes = Theme.ordered_for_interview
      end
    end
  end

  def visite
    if request.post?
      authorize @diagnosis, :update?

      diagnosis_params = params_for_visite
      diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
      diagnosis_params[:step] = 4
      if @diagnosis.update(diagnosis_params)
        redirect_to action: :selection, id: @diagnosis and return
      end
      flash.alert = @diagnosis.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.js { render 'flashes' }
      format.html
    end
  end

  def selection
    if request.post?
      authorize @diagnosis, :update?
      if @diagnosis.match_and_notify!(params_for_matches)
        flash.notice = I18n.t('diagnoses.steps.selection.notifications_sent')
        redirect_to need_path(@diagnosis) and return
      end
      flash.alert = @diagnosis.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.js { render 'flashes' }
      format.html
    end
  end

  private

  def retrieve_diagnosis
    safe_params = params.permit(:id)
    @diagnosis = Diagnosis.find(safe_params[:id])
  end

  def params_for_visite
    permitted = params.require(:diagnosis).permit(:happened_on, visitee_attributes: [:full_name, :role, :email, :phone_number, :id])
    permitted
  end

  def params_for_matches
    matches = params.permit(matches: {}).require(:matches)
    matches.transform_values do |expert_subjects_selection|
      expert_subjects_selection.select{ |_,v| v == '1' }.keys
    end
  end
end
