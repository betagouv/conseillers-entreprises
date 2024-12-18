# frozen_string_literal: true

class SolicitationMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/solicitation_mailer'

  helper :solicitation, :images

  def administrations_collectivites(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def bad_quality(solicitation)
    @solicitation = solicitation
    @cooperation_logo_name = @solicitation.cooperation&.logo&.filename
    @landing_subject = LandingSubject.joins(landing_theme: :landings).find_by(subject: @solicitation.needs&.first&.subject, landings: [@solicitation.landing])
    @landing_subject = @solicitation.landing_subject if @landing_subject.nil?

    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def carsat(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def creation(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def employee_labor_law(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def formalites_asso_agri_sci(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def intermediary(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def kbis_extract(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def mediateurs(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def moderation(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def no_expert(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def recruitment_foreign_worker(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def retirement_liberal_professions(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def sie_sip_declare_and_pay(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def sie_tva_and_others(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def siret(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def tns_training(solicitation)
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end
end
