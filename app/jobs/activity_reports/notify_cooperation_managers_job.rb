class ActivityReports::NotifyCooperationManagersJob < ApplicationJob
  queue_as :low_priority

  def perform
    ActivityReports::NotifyCooperationManagers.new(User.cooperation_managers).call
  end
end
