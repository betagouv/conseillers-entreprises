class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_without_solicitation
    diagnosis = Diagnosis.completed.where(solicitation: nil).joins(:experts).where(experts: { deleted_at: nil }).sample
    expert = diagnosis.experts.not_deleted.sample
    ExpertMailer.notify_company_needs(expert, diagnosis.needs.first)
  end

  def notify_company_needs_with_solicitation
    expert = active_expert
    diagnosis = expert.received_diagnoses.sample
    need = diagnosis.needs.first
    need.solicitation = Solicitation.joins(:landing).where(landing: { partner_url: [nil, ''] }).sample
    ExpertMailer.notify_company_needs(expert, need)
  end

  def notify_company_needs_from_partner
    expert = active_expert
    diagnosis = expert.received_diagnoses.sample
    need = diagnosis.needs.first
    solicitation = Solicitation.all.sample
    need.solicitation = solicitation
    solicitation.landing = Landing.all.sample
    solicitation.landing.update(partner_url: 'https://test.com/formulaire')
    ExpertMailer.notify_company_needs(expert, need)
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
