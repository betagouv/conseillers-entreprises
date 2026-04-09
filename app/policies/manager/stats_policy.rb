class Manager::StatsPolicy < ApplicationPolicy
  def index? = @user&.is_manager? || @user&.is_admin?

  def load_data? = index?
  def load_filter_options? = index?
end
