# frozen_string_literal: true

module ActivityReports
  class NotifyManagers
    def initialize(managers = User.managers)
      @managers = managers
    end

    def call
      @managers.each do |user|
        next unless user.managed_antennes.map { |antenne| antenne.activity_reports.find_by(start_date: 3.months.ago.beginning_of_month) }.any?
        UserMailer.with(user: user).activity_report.deliver_later
      end
    end
  end
end
