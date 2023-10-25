class QuarterlyReports::NotifyManagersJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    User.managers.find_each do |user|
      next unless user.managed_antennes.map { |antenne| antenne.quarterly_reports.find_by(start_date: 3.months.ago.beginning_of_month) }.any?
      UserMailer.quarterly_report(user).deliver_later(queue: 'low_priority')
    end
  end
end
