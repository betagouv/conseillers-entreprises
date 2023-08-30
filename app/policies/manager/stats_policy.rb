class Manager::StatsPolicy < ApplicationPolicy
  def index?
    manager?
  end
end
