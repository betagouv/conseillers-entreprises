# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'

  def confirm_notifications_sent(diagnosis)
    @diagnosis = diagnosis
    @user = @diagnosis.advisor
    mail(to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.confirm_notifications_sent.subject', company: @diagnosis.company.name, count: @diagnosis.needs.size))
  end

  def match_feedback(feedback, person)
    @feedback = feedback
    @person = person
    @author = feedback.author
    mail(to: @person.email_with_display_name,
         reply_to: @author.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: feedback.need.company))
  end

  def notify_match_status(match, previous_status)
    @status = {}
    @match = match
    @expert = match.expert
    @previous_status = previous_status
    @advisor = match.advisor
    @company = match.company
    @need = match.need
    @subject = match.subject
    mail(to: @advisor.email, subject: t('mailers.user_mailer.notify_match_status.subject', company_name: @company.name))
  end

  def self.deduplicated_send_match_notify(match, previous_status)
    if ENV['DEVELOPMENT_INLINE_JOBS'].to_b
      notify_match_status(match, previous_status).deliver_later
      return
    end

    # Kill similar jobs that are not run yet (or being run).
    # Disable DEVELOPMENT_INLINE_JOBS to debug :)
    queue = 'match_notify'
    previous_jobs = Delayed::Job.remove_jobs queue do |job|
      payload = job.payload_object
      # Remove the similar emails about to be sent
      [payload.object, payload.method_name] == [UserMailer, :update_match_notify] &&
        payload.args.first == match
    end

    # Fetch the oldest status from the previous jobs
    old_status = previous_jobs.first&.payload_object&.args&.last
    old_status ||= previous_status

    # Reschedule a new email, if needed.
    if match.status != old_status
      # Use DelayedJob (instead of the abstract layer, ActiveJob) because it’s easier to filter the payload object
      delay(run_at: 1.minute.from_now, queue: queue).notify_match_status(match, old_status)
    end
  end
end
