class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs
    expert = active_expert
    ExpertMailer.notify_company_needs(expert, expert.received_diagnoses.sample)
  end

  def notify_company_needs_from_partner
    expert = active_expert
    diagnosis = expert.received_diagnoses.sample
    solicitation = Solicitation.all.sample
    diagnosis.solicitation = solicitation
    solicitation.landing.update(partner_url: 'https://test.com/formulaire')
    ExpertMailer.notify_company_needs(expert, diagnosis)
  end

  def remind_involvement
    expert = active_expert
    ExpertMailer.remind_involvement(expert)
  end

  def notify_other_taking_care
    ExpertMailer.notify_other_taking_care(Expert.all.sample, Match.all.sample)
  end

  private

  def active_expert
    Expert.with_active_matches.sample
  end
end
