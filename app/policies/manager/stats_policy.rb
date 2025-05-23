class Manager::StatsPolicy < ApplicationPolicy
  def index?
    manager? || admin?
  end
end
