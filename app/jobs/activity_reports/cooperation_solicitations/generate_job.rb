class ActivityReports::CooperationSolicitations::GenerateJob < ApplicationJob
  queue_as :low_priority

  def perform(cooperation_id)
    cooperation = Cooperation.find(cooperation_id)
    ActivityReports::Generate::CooperationSolicitations.new(cooperation).call
  end
end
