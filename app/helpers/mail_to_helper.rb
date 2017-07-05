# frozen_string_literal: true

module MailToHelper
  def expert_contact_button(visit:, question:, assistance:, expert:)
    expert_email = expert.email
    mailto_text = t('assistance.assistance.contact_by_email')
    one_contact_email_button(visit, question, assistance, expert_email, mailto_text)
  end

  def institution_contact_button(visit:, question:, assistance:)
    institution_email = assistance.institution.email
    mailto_text = t('assistance.assistance.contact_institution_by_email')
    one_contact_email_button(visit, question, assistance, institution_email, mailto_text)
  end

  def assistances_contact_all_button(visit:, question:, assistances:)
    mail_to(
      assistances_contact_emails_string_list(assistances),
      t('assistance.assistance.contact_all_with_one_email'),
      bcc: ENV['APPLICATION_EMAIL'],
      subject: mail_to_subject(visit),
      body: assistances_contacts_email_body(visit, question, assistances),
      class: 'ui button green mailto-expert-button',
      target: :_blank,
      data: mail_to_data(visit, question)
    )
  end

  private

  def one_contact_email_button(visit, question, assistance, recipient_email, mailto_text)
    mail_to(
      recipient_email,
      mailto_text,
      bcc: ENV['APPLICATION_EMAIL'],
      subject: mail_to_subject(visit),
      body: one_contact_email_body(visit, question, assistance),
      class: 'ui button green mailto-expert-button mini',
      target: :_blank,
      data: mail_to_data(visit, question, assistance)
    )
  end

  def one_contact_email_body(visit, question, assistance) # rubocop:disable Metrics/MethodLength
    email_template_locals = {
      visit_date: visit.happened_at_localized,
      company_name: visit.company_name,
      company_user: visit.visitee,
      need: question.label,
      advisor_user: current_user,
      offer: assistance.title,
      email_specific_sentence: assistance.email_specific_sentence,
      expert_institution: assistance.institution.name
    }
    email_body = render partial: 'visits/email_to_expert', locals: email_template_locals
    strip_tags email_body
  end

  def assistances_contacts_email_body(visit, question, assistances)
    email_template_locals = {
      visit_date: visit.happened_at_localized,
      company_name: visit.company_name,
      company_user: visit.visitee,
      need: question.label,
      advisor_user: current_user,
      assistances: assistances_hash(assistances)
    }
    email_body = render partial: 'visits/grouped_email_to_experts', locals: email_template_locals
    strip_tags email_body
  end

  def assistances_contact_emails_string_list(assistances)
    recipients_emails = []
    assistances.each do |assistance|
      if assistance.has_experts?
        assistance.experts.each { |expert| recipients_emails << expert.email }
      else
        recipients_emails << assistance.institution.email
      end
    end
    recipients_emails.uniq.join(',')
  end

  def assistances_hash(assistances)
    assistances_hash = []
    assistances.each do |assistance|
      assistances_hash << { title: assistance.title, institution: assistance.institution }
    end
  end

  def mail_to_subject(visit)
    "#{t('app_name')} - #{t('assistance.assistance.company_needs_you', company_name: visit.company_name)}"
  end

  def mail_to_data(visit, question, assistance = nil)
    {
      logged: false,
      log_path: mailto_logs_path(
        mailto_log: {
          question_id: question.id,
          visit_id: visit.id,
          assistance_id: assistance&.id
        }
      )
    }
  end
end
