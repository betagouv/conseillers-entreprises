class FacilityPolicy < ApplicationPolicy
  def show_needs_history?
    (admin? && @record.needs.diagnosis_completed.any?) ||
      @user.received_needs.joins(diagnosis: :facility).where(diagnoses: { facility: @record }).any?
  end
end
