class DiagnosisPolicy < ApplicationPolicy
  def show?
    if user.present?
      admin? ||
          @record.advisor == user ||
          support?(user, @record) ||
          @record.advisor.antenne == user.antenne ||
          @record.in?(user&.received_diagnoses)
    else
      @record.in?(expert&.received_diagnoses)
    end
  end

  def update?
    show?
  end

  def destroy?
    admin?
  end
end
