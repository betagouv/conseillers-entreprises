class SolicitationPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def mark_as_spam?
    admin?
  end
end
