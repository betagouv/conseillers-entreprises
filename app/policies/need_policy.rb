class NeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.received_by(user)
      end
    end
  end

  def show?
    admin? ||
      @record.advisor == @user ||
      support?(@user, @record) ||
      @record.advisor_antenne == @user.antenne ||
      @record.in?(@user&.received_needs) ||
      @record.in?(@user.antenne.received_needs) ||
      # Manager d'une ou plusieurs antennes, de tout niveau
      (@user.is_manager? && (@record.expert_antennes.any? { |antenne| @user.supervised_antennes.include?(antenne) }))
  end

  def show_need_actions?
    @record.matches.find_by(expert: @user.experts).present?
  end

  def add_match?
    admin?
  end

  def star?
    admin?
  end
end
