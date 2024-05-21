class QuarterlyReports::NotifyManagersJob < ApplicationJob
  queue_as :low_priority

  def perform
    User.managers.find_each do |user|
      next unless user.managed_antennes.map { |antenne| antenne.quarterly_reports.find_by(start_date: 3.months.ago.beginning_of_month) }.any?
      UserMailer.with(user: user).quarterly_report.deliver_later
    end
  end
end
