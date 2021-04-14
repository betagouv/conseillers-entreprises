class FacilityPolicy < ApplicationPolicy
  def show_needs_history?
    if admin?
      @record.needs.diagnosis_completed.any?
    else
      @user.received_needs.for_facility(@record).any?
    end
  end
end
