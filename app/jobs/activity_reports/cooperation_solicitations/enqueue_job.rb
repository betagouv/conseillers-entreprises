class ActivityReports::CooperationSolicitations::EnqueueJob < ApplicationJob
  queue_as :low_priority

  def perform
    Cooperation.not_archived.where(wants_solicitations_export: true).find_each do |cooperation|
      ActivityReports::CooperationSolicitations::GenerateJob.perform_later(cooperation.id)
    end
  end
end
