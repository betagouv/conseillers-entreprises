class MatchPolicy < ApplicationPolicy
  def update?
    admin? || @record.contacted_users.include?(@user)
  end

  def update_status?
    admin? || (@user.is_manager? && (@user.managed_antennes.include?(@record.expert.antenne)))
  end

  def show_info?
    admin?
  end

  def show_inbox?
    admin?
  end
end
