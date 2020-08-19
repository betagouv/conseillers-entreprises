class MatchPolicy < ApplicationPolicy
  def update?
    admin? || @record.contacted_users.include?(@user)
  end

  def mark_as_done?
    admin?
  end
end
