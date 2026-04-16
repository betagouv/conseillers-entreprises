class CooperationPolicy < ApplicationPolicy
  def index? = @user&.is_admin? || @user&.is_cooperation_manager?

  def manage?
    @user&.is_admin? ||
    (@user&.is_cooperation_manager? && @user.managed_cooperations.include?(@record))
  end
end
