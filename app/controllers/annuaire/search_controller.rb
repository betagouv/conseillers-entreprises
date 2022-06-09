module Annuaire
  class SearchController < BaseController
    def search
      model, id = params[:query].split('-')

      case model
      when 'User'
        user = User.find(id)
        redirect_to institution_users_path(user.institution.slug, { advisor: user, antenne_id: user.antenne.id })
      when 'Antenne'
        antenne = Antenne.find(id)
        redirect_to institution_users_path(antenne.institution.slug, antenne_id: antenne.id)
      when 'Institution'
        institution = Institution.find(id)
        redirect_to institution_users_path(institution.slug)
      else
        redirect_back(fallback_location: institutions_path)
      end
    end

    # TODO enlever ça
    def many_users
      @advisors = User.where(id: params[:advisors])
    end

    def no_user; end

    def autocomplete
      @results = Institution.omnisearch(params[:q]).limit(7) +
        Antenne.omnisearch(params[:q]).limit(7) +
        User.omnisearch(params[:q]).limit(7)
      render layout: false
    end
  end
end
