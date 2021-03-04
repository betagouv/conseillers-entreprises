class FacilityPolicy < ApplicationPolicy
  def show_needs_history?
    (admin? && @record.needs.where.not(status: :diagnosis_not_complete).many?) || @user.received_needs.joins(diagnosis: :facility).where(diagnoses: { facility: @record }).many?
  end
end
