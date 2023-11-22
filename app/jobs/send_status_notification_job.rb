class SendStatusNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: 'match_notification'

  def perform(match_id, previous_status)
    match = Match.find(match_id)
    if should_notify_everyone(previous_status, match.status)
      # Notify the company
      CompanyMailer.notify_taking_care(match).deliver_later
    end
    if match.status.to_sym == :done_not_reachable
      CompanyMailer.notify_not_reachable(match).deliver_later
    end
  end

  private

  def should_notify_everyone(old_status, new_status)
    not_taken_care_of = %w[quo not_for_me]
    taken_care_of = %w[taking_care done]

    old_status.in?(not_taken_care_of) && new_status.in?(taken_care_of)
  end
end
