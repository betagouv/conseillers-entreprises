class ExpertPolicy < ApplicationPolicy
  def show?
    admin? || @record.users.include?(@user)
  end

  def edit?
    show?
  end

  def update?
    edit? && @record.can_edit_own_subjects
  end
end
