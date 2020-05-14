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
      visitee = Contact.create(full_name: @diagnosis.solicitation.full_name,
                               email: @diagnosis.solicitation.email,
                               phone_number: @diagnosis.solicitation.phone_number,
                               company: @diagnosis.facility.company,
                               role: t('contact.default_role_from_solicitation'))
      @diagnosis.update(visitee: visitee)
    end
  end

  def update_visit
    authorize @diagnosis, :update?

    diagnosis_params = params_for_visit
    diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
    diagnosis_params[:step] = :matches

    if @diagnosis.update(diagnosis_params)
      redirect_to action: :matches
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      redirect_to action: :visit
    end
  end

  def matches
    # TODO: experimental/preliminary support for automatic diagnoses #940
    if ENV['FEATURE_PRESELECT_DIAGNOSIS'].to_b && @diagnosis.matches.blank? && @diagnosis.solicitation.present?
      institutions = @diagnosis.solicitation.preselected_institutions
      @diagnosis.needs.each do |need|
        relevant_expert_subjects = ExpertSubject.relevant_for(need)
        relevant_expert_subjects = relevant_expert_subjects
          .joins(institution_subject: :institution)
          .where(institutions_subjects: { institution: institutions })
        # do not filter with specialist/fallback here, the institution selection overrides this
        need.matches = relevant_expert_subjects.map { |expert_subject| Match.new(expert: expert_subject.expert, subject: expert_subject.subject) }
      end
    end
  end

  def update_matches
    authorize @diagnosis, :update?

    diagnosis_params = params_for_matches
    diagnosis_params[:step] = :completed

    if @diagnosis.update(diagnosis_params)
      @diagnosis.notify_matches_made!
      @diagnosis.solicitation&.status_processed!
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
    params.require(:diagnosis)
      .permit(needs_attributes: [:id, matches_attributes: [:_destroy, :id, :subject_id, :expert_id]])
  end
end
