class ErasePastAbsencesJob < ApplicationJob
  queue_as :low_priority

  def perform
    User.where(absence_end_at: ...Time.zone.now).update_all(absence_start_at: nil, absence_end_at: nil)
  end
end
