module Annuaire
  class SearchController < BaseController
    def search
      model, id = params[:query].split('-')
      institution_slug, antenne_id, advisor_id = fetch_institution_and_antenne(model, id)

      redirect_to institutions_path and return if institution_slug.nil?
      redirect_to institution_users_path(institution_slug, antenne_id: antenne_id, advisor: advisor_id, **form_params)
    end

    def autocomplete
      @results = Institution.omnisearch(params[:q]).limit(7) +
        Antenne.omnisearch(params[:q]).limit(7) +
        User.omnisearch(params[:q]).limit(7)
      render layout: false
    end

    private

    def fetch_institution_and_antenne(model, id)
      case model
      when 'User'
        user = User.find(id)
        form_params[:advisor] = user
        [user.institution.slug, user.antenne.id, user.id]
      when 'Antenne'
        antenne = Antenne.find(id)
        [antenne.institution.slug, antenne.id, nil]
      when 'Institution'
        institution = Institution.find(id)
        [institution.slug, nil, nil]
      else
        if params[:institution_slug].present?
          [params[:institution_slug], nil, nil]
        else
          [nil, nil, nil]
        end
      end
    end
  end
end
