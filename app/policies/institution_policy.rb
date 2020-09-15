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

  def import_antennes?
    admin?
  end

  def import_advisors?
    admin?
  end
end
