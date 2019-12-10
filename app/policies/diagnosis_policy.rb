class DiagnosisPolicy < ApplicationPolicy
  def show?
    admin? || @record.advisor_id == @user.id || support?(@user, @record) || @record.advisor.antenne == @user.antenne
  end

  def update?
    show?
  end

  def destroy?
    admin?
  end
end
