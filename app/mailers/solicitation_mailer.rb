# frozen_string_literal: true

class SolicitationMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/solicitation_mailer'

  def bad_quality_difficulties(solicitation)
    @subject_label = solicitation.landing_subject.subject.label.downcase

    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def bad_quality_investment(solicitation)
    @subject_label = solicitation.landing_subject.subject.label.downcase

    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def employee_labor_law(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def out_of_region(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def moderation(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def creation(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def siret(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def particular_retirement(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end
end
