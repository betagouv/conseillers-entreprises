class Manager::NeedsPolicy < ApplicationPolicy
  def index?
    manager?
  end
end
