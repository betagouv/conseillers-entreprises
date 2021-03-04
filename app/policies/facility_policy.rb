class FacilityPolicy < ApplicationPolicy
  def show_needs_history?
    (admin? && @record.needs.diagnosis_completed.many?) || @user.received_needs.joins(diagnosis: :facility).where(diagnoses: { facility: @record }).many?
  end
end
