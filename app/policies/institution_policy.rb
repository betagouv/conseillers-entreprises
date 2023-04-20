class InstitutionPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def index_better?
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

  def search?
    admin?
  end

  def clear_search?
    search?
  end

  def send_invitations?
    admin?
  end
end
