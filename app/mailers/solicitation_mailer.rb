class SolicitationMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/solicitation_mailer'

  helper :solicitation, :images

  def administrations_collectivites(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'administrations_collectivites')
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
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'carsat')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def creation(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'creation')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def employee_labor_law(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'employee_labor_law')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def formalites_asso_agri_sci(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'formalites_asso_agri_sci')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def intermediary(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'intermediary')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def kbis_extract(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'kbis_extract')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def mediateurs(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'mediateurs')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def moderation(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'moderation')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def no_expert(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'no_expert')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def no_expert_agri(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'no_expert_agri')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def recruitment_foreign_worker(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'recruitment_foreign_worker')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def retirement_liberal_professions(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'retirement_liberal_professions')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def sie_sip_declare_and_pay(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'sie_sip_declare_and_pay')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def sie_tva_and_others(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'sie_tva_and_others')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def siret(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'siret')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end

  def tns_training(solicitation)
    @solicitation_mail_template = SolicitationMailTemplate.find_by!(email_type: 'tns_training')
    mail(to: solicitation.email, subject: t('mailers.solicitation.subject'))
  end
end
