class SharedSatisfactionPolicy < ApplicationPolicy
  def show_navbar?
    return false if @user&.is_manager? || @user&.is_admin?
    true
  end
end
