class MatchPolicy < ApplicationPolicy
  def update?
    admin? || @record.contacted_users.include?(@user)
  end
end
