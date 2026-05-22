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

  def self.method_missing(method_name, *args)
    if SolicitationMailTemplate.exists?(email_type: method_name.to_s)
      class_eval do
        define_method(method_name) do |solicitation|
          @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: method_name.to_s)
          mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
        end
      end
      super
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    SolicitationMailTemplate.exists?(email_type: method_name.to_s) || super
  end
end
