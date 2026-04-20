class Manager::NeedsPolicy < ApplicationPolicy
  def index? = @user&.is_manager?
end
