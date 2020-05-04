class Diagnoses::StepsController < ApplicationController
  before_action :retrieve_diagnosis

  def needs
    @themes = Theme.ordered_for_interview

    # TODO: experimental/preliminary support for automatic diagnoses #940
    if ENV['FEATURE_PRESELECT_DIAGNOSIS'].to_b && @diagnosis.needs.blank? && @diagnosis.solicitation.present?
      subjects = @diagnosis.solicitation.preselected_subjects
      @diagnosis.needs = subjects.map { |subject| Need.new(subject: subject) }
    end
  end

  def update_needs
    authorize @diagnosis, :update?

    diagnosis_params = params_for_needs
    diagnosis_params[:step] = :visit
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :visit
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      redirect_to action: :needs
    end
  end

  def visit
    if @diagnosis.visitee.nil? && @diagnosis.solicitation.present?
      @diagnosis.visitee = Contact.new(full_name:  @diagnosis.solicitation.full_name, email: @diagnosis.solicitation.email,
                            phone_number: @diagnosis.solicitation.phone_number)
    end
  end

  def update_visit
    authorize @diagnosis, :update?

    diagnosis_params = params_for_visit
    diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
    diagnosis_params[:step] = :matches

    begin
      @diagnosis.transaction do
        @diagnosis.update!(diagnosis_params)
        @diagnosis.solicitation&.status_processed!
        redirect_to action: :matches
      end
    rescue ActiveRecord::ActiveRecordError => e
      flash.alert = e.message
      redirect_to action: :visit
    end
  end

  def matches
  end

  def update_matches
    authorize @diagnosis, :update?
    if @diagnosis.match_and_notify!(params_for_matches)
      flash.notice = I18n.t('diagnoses.steps.matches.notifications_sent')
      redirect_to need_path(@diagnosis)
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      redirect_to action: :matches
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
              visitee_attributes: [:full_name, :role, :email, :phone_number, :id],
              facility_attributes: [:insee_code, :id])
  end

  def params_for_matches
    matches = params.permit(matches: {}).require('matches')
    matches.transform_values do |expert_subjects_selection|
      expert_subjects_selection.select{ |_,v| v == '1' }.keys
    end
  end
end
