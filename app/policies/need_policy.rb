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
      (@user.is_manager? && (@record.expert_antennes.any? { |antenne| authorized_antennes.include?(antenne) }))
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

  def authorized_antennes
    ids = @user.managed_antennes.each_with_object([]) do |managed_antenne, array|
      array.push(*managed_antenne.territorial_antennes.pluck(:id))
    end
    ids.push(*@user.managed_antenne_ids)
    Antenne.where(id: ids)
  end
end
