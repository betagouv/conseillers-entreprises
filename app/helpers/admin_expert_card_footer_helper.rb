module AdminExpertCardFooterHelper
  def build_admin_expert_card_footer(action, expert)
    html = ""
    html << expert_email_button(action, expert) if EXPERT_EMAILS.key?(action)
    html << expert_action_button(action, expert) if EXPERT_ACTIONS.key?(action)
    html
  end

  EXPERT_EMAILS = {
    inputs: :reminder_email,
    many_pending_needs: :reminder_email,
    medium_pending_needs: :reminder_email,
    one_pending_need: :re_engagement_email,
    taking_care_matches: :closing_good_practice_email
  }.freeze

  EXPERT_ACTIONS = {
    inputs: :input_register,
    expired_needs: :expired_need_register,
    outputs: :output_register
  }.freeze

  private

  ## Emails
  #
  def expert_email_button(action, expert)
    button = send(EXPERT_EMAILS[action], expert)
    tag.div(button, id: "expert-email-#{expert.id}")
  end

  def re_engagement_email(expert)
    expert_email_form_builder(send_re_engagement_email_reminders_expert_path(expert), t('reminders.experts.send_re_engagement_email.label'), expert)
  end

  def reminder_email(expert)
    expert_email_form_builder(send_reminder_email_reminders_expert_path(expert), t('reminders.experts.send_reminder_email.label'), expert)
  end

  def closing_good_practice_email(expert)
    expert_email_form_builder(send_closing_good_practice_email_conseiller_veille_path(expert), t('reminders.experts.send_closing_good_practice_email.label'), expert)
  end

  def expert_email_form_builder(path, text, expert, form_options = {})
    form_with(model: expert, url: path, method: :post, data: { turbo: true }, **form_options) do |f|
      f.submit text, class: 'fr-btn fr-btn--secondary fr-mr-2v'
    end.html_safe
  end

  ## Actions
  #
  def expert_action_button(action, expert)
    reminders_register = expert.send(EXPERT_ACTIONS[action])
    if reminders_register.present?
      form_with(model: expert, url: reminders_reminders_register_path(reminders_register), method: :patch, local: true, data: { turbo: false }) do |f|
        f.submit t('reminders.process'), class: 'fr-btn fr-mr-2v'
      end.html_safe
    end
  end
end
