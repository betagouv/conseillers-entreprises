class CooperationPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? ||
    (@user&.is_cooperation_manager?)
  end

  def manage?
    @user&.is_admin? ||
    (@user&.is_cooperation_manager? && @user.managed_cooperations.include?(@record))
  end

  def show_navbar?
    @user&.is_cooperation_manager?
  end

  def show_navbar_cooperation_matches?
    @user&.is_cooperation_manager? && @user.managed_cooperations.any?{ |c| c.display_matches_stats? }
  end
end
