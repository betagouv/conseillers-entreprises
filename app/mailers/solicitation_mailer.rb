# frozen_string_literal: true

class SolicitationMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/solicitation_mailer'

  def bad_quality(solicitation)
    @solicitation = solicitation
    @subject_label = @solicitation&.diagnosis&.needs&.first&.subject&.label.presence || @solicitation.landing_subject.title
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def employee_labor_law(solicitation)
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

  def independent_tva(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def intermediary(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def recruitment_foreign_worker(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def no_expert(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def carsat(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def tns_training(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def kbis_extract(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end
end
