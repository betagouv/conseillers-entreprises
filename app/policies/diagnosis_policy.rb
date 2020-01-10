class DiagnosisPolicy < ApplicationPolicy
  def show?
    admin? ||
        @record.advisor == @user ||
        support?(@user, @record) ||
        @record.advisor.antenne == @user.antenne ||
        @record.in?(@user&.received_diagnoses)
  end

  def update?
    show?
  end

  def destroy?
    admin?
  end
end
