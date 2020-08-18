class InstitutionPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def subjects?
    show?
  end

  def update?
    admin?
  end
end
