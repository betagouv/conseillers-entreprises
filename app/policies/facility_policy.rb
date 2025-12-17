class FacilityPolicy < ApplicationPolicy
  def needs?
    if admin?
      @record.needs.diagnosis_completed.any?
    else
      @user.received_needs.for_facility(@record).any?
    end
  end
end
