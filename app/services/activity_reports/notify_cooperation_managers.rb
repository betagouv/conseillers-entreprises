module ActivityReports
  class NotifyCooperationManagers
    def initialize(managers = User.cooperation_managers)
      @managers = managers
    end

    def call
      @managers.each do |user|
        user.managed_cooperations.each do |cooperation|
          recent_reports = cooperation.activity_reports.find_by(start_date: 3.months.ago.beginning_of_month)
          next if recent_reports.blank?
          UserMailer.with(user: user, cooperation: cooperation).cooperation_activity_report.deliver_later
        end
      end
    end
  end
end
