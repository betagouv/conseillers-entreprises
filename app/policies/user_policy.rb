class UserPolicy < ApplicationPolicy
  def admin?
    @user&.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end
