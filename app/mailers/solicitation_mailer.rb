class SolicitationMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/solicitation_mailer'

  helper :solicitation, :images

  def bad_quality(solicitation)
    @solicitation = solicitation
    @cooperation_logo_name = @solicitation.cooperation&.logo&.filename
    @landing_subject = LandingSubject.joins(landing_theme: :landings).find_by(subject: @solicitation.needs&.first&.subject, landings: [@solicitation.landing])
    @landing_subject = @solicitation.landing_subject if @landing_subject.nil?

    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def template(solicitation, email_type)
    @solicitation = solicitation
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: email_type)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'), template_name: 'solicitation_mail_template')
  end
end
