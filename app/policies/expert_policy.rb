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

  def update_subjects?
    update? && @record.can_edit_own_subjects
  end
end
