class ActivityReports::NotifyManagersJob < ApplicationJob
  queue_as :low_priority

  def perform
    ActivityReports::NotifyManagers.new(User.managers).call
  end
end
