class Conseiller::Diagnoses::StepsController < ApplicationController
  before_action :retrieve_diagnosis

  def contact
    DiagnosisCreation::Steps.new(@diagnosis).prepare_happened_on_from_solicitation
    DiagnosisCreation::Steps.new(@diagnosis).prepare_visitee_from_solicitation
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
    DiagnosisCreation::Steps.new(@diagnosis).prepare_needs_from_solicitation
  end

  def update_needs
    authorize @diagnosis, :update?

    diagnosis_params = params_for_needs
    diagnosis_params[:step] = :matches
    if @diagnosis.update(diagnosis_params)
      if params[:diagnosis][:submit] == 'return_solicitation_page'
        redirect_to conseiller_solicitation_path(@diagnosis.solicitation)
      else
        redirect_to action: :matches
      end
    else
      @themes = Theme.ordered_for_interview
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render :needs
    end
  end

  def matches
    DiagnosisCreation::Steps.new(@diagnosis).prepare_matches_from_solicitation
    @company_needs = @diagnosis.facility.needs.diagnosis_completed
    @contact_needs = Need.for_emails_and_sirets([@diagnosis.visitee.email])
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
      flash.notice = I18n.t('conseiller.diagnoses.steps.matches.notifications_sent')
      redirect_to conseiller_solicitations_path
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      render :matches, status: :unprocessable_entity
    end
  end

  def add_match
    @need = Need.find(params.require(:need_id))
    @expert = Expert.find(params.require(:expert_id))
    @match = Match.new(need: @need, expert: @expert, subject: @need.subject)
    unless @match.save
      flash.alert = @match.errors.full_messages.to_sentence
    end
    render :matches
  end

  private

  def retrieve_diagnosis
    @diagnosis = Diagnosis.find(params.require(:id))
  end

  def params_for_needs
    params.require(:diagnosis)
      .permit(:content, needs_attributes: [:_destroy, :content, :subject_id, :id, subject_answers_attributes: [:_destroy, :id, :subject_question_id, :filter_value]])
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
