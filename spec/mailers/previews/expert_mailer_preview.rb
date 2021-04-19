class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_without_solicitation
    diagnosis = Diagnosis.completed.where(solicitation: nil).joins(:experts).where(experts: { deleted_at: nil }).sample
    expert = diagnosis.experts.not_deleted.sample
    ExpertMailer.notify_company_needs(expert, diagnosis)
  end

  def notify_company_needs_with_solicitation
    expert = active_expert
    diagnosis = expert.received_diagnoses.sample
    diagnosis.solicitation = Solicitation.all.sample
    ExpertMailer.notify_company_needs(expert, diagnosis)
  end

  def notify_company_needs_from_partner
    expert = active_expert
    diagnosis = expert.received_diagnoses.sample
    solicitation = Solicitation.all.sample
    diagnosis.solicitation = solicitation
    solicitation.landing = Landing.all.sample
    solicitation.landing.update(partner_url: 'https://test.com/formulaire')
    ExpertMailer.notify_company_needs(expert, diagnosis)
  end

  def first_notification_help
    expert = active_expert
    ExpertMailer.first_notification_help(expert)
  end

  def remind_involvement
    expert = active_expert
    ExpertMailer.remind_involvement(expert)
  end

  private

  def active_expert
    Expert.not_deleted.with_active_matches.sample
  end
end
