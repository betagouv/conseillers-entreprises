class SolicitationMailerPreview < ActionMailer::Preview
  def bad_quality
    SolicitationMailer.bad_quality(Solicitation.joins(:landing_subject).status_canceled.have_badge('mauvaise_qualité').find_random)
  end

  # Dynamically define preview methods for all generic email types defined in the database.
  SolicitationMailTemplate.pluck(:email_type).each do |email_type|
    define_method(email_type) do
      SolicitationMailer.template(random_solicitation, email_type)
    end
  end

  private

  def random_solicitation
    Solicitation.step_complete.joins(:landing_subject).find_random
  end
end
