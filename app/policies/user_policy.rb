class UserPolicy < ApplicationPolicy
  def admin?
    @user&.is_admin?
  end

  def manager?
    @user.is_manager?
  end

  def cooperation_manager?
    @user.is_cooperation_manager?
  end
end
