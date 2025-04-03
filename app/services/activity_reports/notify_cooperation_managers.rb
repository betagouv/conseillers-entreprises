# frozen_string_literal: true

module ActivityReports
  class NotifyCooperationManagers
    def initialize(managers = User.cooperation_managers)
      @managers = managers
    end

    def call
      @managers.each do |user|
        next unless user.managed_cooperations.map { |cooperation| cooperation.activity_reports.find_by(start_date: 3.months.ago.beginning_of_month) }.any?
        UserMailer.with(user: user).cooperation_activity_report.deliver_later
      end
    end
  end
end
