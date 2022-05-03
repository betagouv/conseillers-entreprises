class AntennePolicy < ApplicationPolicy
  def show_manager?
    UserPolicy.admin?
  end
end
