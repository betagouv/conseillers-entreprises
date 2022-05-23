class DiagnosisPolicy < ApplicationPolicy
  def index?
    @user.can_view_diagnoses_tab
  end

  def show?
    admin? ||
        @record.advisor == @user ||
        support?(@user, @record) ||
        @record.advisor&.antenne == @user.antenne ||
        @record.in?(@user.antenne.received_diagnoses) ||
        @record.in?(@user&.received_diagnoses)
  end

  def update?
    show?
  end

  def new?
    index?
  end

  def destroy?
    admin?
  end
end
