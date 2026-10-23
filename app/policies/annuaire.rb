module Annuaire
  class InstitutionPolicy < ApplicationPolicy
    def index? = admin?

    def show? = admin?
  end

  class SubjectPolicy < ApplicationPolicy
    def index? = admin?
  end

  class AntennePolicy < ApplicationPolicy
    def index? = admin?
  end

  class UserPolicy < ApplicationPolicy
    def index? = admin?

    def send_invitations? = admin?

    def create_territorial_coverage? = admin?
  end

  class SearchPolicy < ApplicationPolicy
    def search? = admin?

    def autocomplete? = admin?
  end

  class FileImportPolicy < ApplicationPolicy
    def new? = admin?

    def create? = admin?

    def update? = admin?

    def analysis? = admin?

    def preview? = admin?

    def commit? = admin?
  end
end
