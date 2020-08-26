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

  def antennes?
    show?
  end

  def advisors?
    show?
  end

  def update?
    admin?
  end
end
