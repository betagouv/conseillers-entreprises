class InstitutionPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def subjects?
    admin?
  end

  def antennes?
    admin?
  end

  def advisors?
    admin?
  end

  def import?
    admin?
  end

  def import_create?
    admin?
  end
end
