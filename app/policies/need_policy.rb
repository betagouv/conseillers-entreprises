class NeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    admin? ||
      @record.advisor == @user ||
      support?(@user, @record) ||
      @record.advisor_antenne == @user.antenne ||
      @record.in?(@user.antenne.received_needs) ||
      @record.in?(@user&.received_needs)
  end

  def has_match_for_user?
    @record.matches.find_by(expert: @user.experts).present?
  end

  def archive?
    admin?
  end
end
