class SharedSatisfactionPolicy < ApplicationPolicy
  def show_navbar?
    return false if @user&.is_manager? || @user&.is_admin?
    true
  end

  def mark_as_seen?
    @record.user == @user
  end
end
