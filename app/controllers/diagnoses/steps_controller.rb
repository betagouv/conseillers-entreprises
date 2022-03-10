class Diagnoses::StepsController < ApplicationController
  before_action :retrieve_diagnosis

  def contact
    @diagnosis.prepare_happened_on_from_solicitation
    @diagnosis.prepare_visitee_from_solicitation
  end

  def update_contact
    authorize @diagnosis, :update?

    diagnosis_params = params_for_visit
    diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
    diagnosis_params[:step] = :needs if @diagnosis.step != 'matches'

    if @diagnosis.update(diagnosis_params)
      redirect_to action: :needs
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render :contact
    end
  end

  def needs
    @themes = Theme.ordered_for_interview

    @diagnosis.prepare_needs_from_solicitation
  end

  def update_needs
    authorize @diagnosis, :update?

    diagnosis_params = params_for_needs
    diagnosis_params[:step] = :matches
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :matches
    else
      @themes = Theme.ordered_for_interview
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render :needs
    end
  end

  def matches
    @diagnosis.prepare_matches_from_solicitation
    @company_needs = @diagnosis.facility.needs.diagnosis_completed
    @contact_needs = Need.historic(@diagnosis.visitee.email)
  end

  def update_matches
    authorize @diagnosis, :update?

    diagnosis_params = params_for_matches
    diagnosis_params[:step] = :completed
    diagnosis_params[:completed_at] = Time.zone.now
    # Automated diagnoses have no advisor: assign the current_user now.
    diagnosis_params[:advisor] = current_user if @diagnosis.advisor.nil?

    if @diagnosis.update(diagnosis_params)
      @diagnosis.notify_matches_made!
      @diagnosis.solicitation&.process!
      flash.notice = I18n.t('diagnoses.steps.matches.notifications_sent')
      redirect_to solicitations_path
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render :matches
    end
  end

  private

  def retrieve_diagnosis
    @diagnosis = Diagnosis.find(params.require(:id))
  end

  def params_for_needs
    params.require(:diagnosis)
      .permit(:content, needs_attributes: [:_destroy, :content, :subject_id, :id])
  end

  def params_for_visit
    params.require(:diagnosis)
      .permit(:happened_on,
              visitee_attributes: [:full_name, :email, :phone_number, :id],
              facility_attributes: [:insee_code, :id])
  end

  def params_for_matches
    params.require(:diagnosis)
      .permit(:content, needs_attributes: [:id, matches_attributes: [:_destroy, :id, :subject_id, :expert_id]])
  end
end
