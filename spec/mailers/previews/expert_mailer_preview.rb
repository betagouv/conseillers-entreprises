class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs
    expert = active_expert
    ExpertMailer.notify_company_needs(expert, expert.received_diagnoses.sample)
  end

  def remind_involvement
    expert = active_expert
    ExpertMailer.remind_involvement(expert)
  end

  private

  def active_expert
    Expert.with_active_matches.sample
  end
end
