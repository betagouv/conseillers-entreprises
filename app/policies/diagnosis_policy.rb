class DiagnosisPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def update?
    admin?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end
end
