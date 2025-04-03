class ActivityReports::NotifyAntenneManagersJob < ApplicationJob
  queue_as :low_priority

  def perform
    ActivityReports::NotifyAntenneManagers.new(User.managers).call
  end
end
