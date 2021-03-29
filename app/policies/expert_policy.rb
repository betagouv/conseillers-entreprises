class ExpertPolicy < ApplicationPolicy
  def show?
    admin? || @record.users.include?(@user)
  end

  def edit?
    show?
  end

  def update?
    edit?
  end
end
