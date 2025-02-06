class SharedSatisfactionPolicy < ApplicationPolicy
  def show_navbar?
    @user.is_manager? || @user.experts.present?
  end
end
