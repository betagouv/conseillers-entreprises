class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation
    CompanyMailer.confirmation_solicitation(email)
  end

  private

  def email
    Solicitation.all.sample.email
  end
end
