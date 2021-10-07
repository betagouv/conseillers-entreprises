class MatchPolicy < ApplicationPolicy
  def update?
    admin? || @record.contacted_users.include?(@user)
  end

  def update_status?
    admin?
  end
end
