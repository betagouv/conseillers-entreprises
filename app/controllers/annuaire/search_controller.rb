module Annuaire
  class SearchController < BaseController
    include LoadFilterOptions
    before_action :init_filters, only: %i[load_filter_options]

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
      # return [institution_slug, antenne_id, advisor_id]
      # Si c'est un utilisateur qui est cherché on vide les filtres et on va à l'utilisateur
      # pour éviter de ne pas trouver cet utilisateur
      # si c'est une antenne on vide la région et on va a l'antenne
      # si c'est un institution on garde les filtres et on va à l'institution
      case model
      when 'User'
        user = User.find(id)
        reset_params_for_user
        form_params[:advisor] = user
        [user.institution.slug, user.antenne.id, user.id]
      when 'Antenne'
        reset_params_for_antenne
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

    def reset_params_for_user
      params[:region] = nil
      params[:theme] = nil
      params[:subject] = nil
      reset_session
    end

    def reset_params_for_antenne
      params[:region] = nil
      session[:annuaire_search].delete('region')
      index_search_params[:region] = nil
    end
  end
end
