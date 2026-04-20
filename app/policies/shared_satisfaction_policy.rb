class SharedSatisfactionPolicy < ApplicationPolicy
  def index? = @user.is_admin? || @user.is_manager? || @user.experts.present?
end
