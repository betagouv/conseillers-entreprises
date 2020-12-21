class Stats::AllPolicy < ApplicationPolicy
  def team?
    admin?
  end
end
