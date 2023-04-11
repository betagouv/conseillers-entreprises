class Reminders::ExpertsControllerPolicy < ApplicationPolicy
  def index?
    admin?
  end
end
