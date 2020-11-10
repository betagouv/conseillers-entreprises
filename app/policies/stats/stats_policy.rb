class Stats::StatsPolicy < ApplicationPolicy
  def team?
    admin?
  end
end
