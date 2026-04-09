class Manager::StatsPolicy < ApplicationPolicy
  def index? = @user&.is_manager? || @user&.is_admin?
end
