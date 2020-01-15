class ExpertPolicy < ApplicationPolicy
  def edit?
    admin? || @record.users.include?(@user)
  end

  def update?
    edit?
  end
end
