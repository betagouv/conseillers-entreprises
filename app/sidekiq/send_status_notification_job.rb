class SendStatusNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: 'match_notify'

  def perform(match_id, previous_status)
    match = Match.find(match_id)
    if should_notify_everyone(previous_status, match.status)
      # Notify the company
      logger.info "premier"
      CompanyMailer.notify_taking_care(match).deliver_later(queue: 'low_priority')
    end
    if match.status == :done_not_reachable
      logger.info "deuxieme"
      CompanyMailer.notify_not_reachable(match).deliver_later(queue: 'low_priority')
    end
  end

  private

  def should_notify_everyone(old_status, new_status)
    not_taken_care_of = %w[quo not_for_me]
    taken_care_of = %w[taking_care done]

    old_status.in?(not_taken_care_of) && new_status.in?(taken_care_of)
  end
end
