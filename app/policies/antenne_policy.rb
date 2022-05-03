class AntennePolicy < ApplicationPolicy
  def show_manager?
    admin?
  end
end
