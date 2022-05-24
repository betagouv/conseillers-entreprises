module Annuaire
  class SearchController < BaseController
    def search
      institution = Institution.find_by(slug: params[:by_institution])
      advisors = form_params.keys.inject(User.not_deleted) do |relation, filter|
        next relation if params[filter].blank?
        relation.send(filter, params[filter])
      end
      antennes = advisors.collect(&:antenne).uniq

      # si il y a un seul utilisateur de trouvé
      # On affiche l'utilisateur au sein de son antenne
      if advisors.size == 1
        advisor = advisors.first
        redirect_to institution_users_path(institution.slug, { advisor: advisor, antenne_id: advisor.antenne }.merge(form_params))

      # Si il y a un paramètre pour la recherche par nom et plusieurs utilisateurs
      # On redirige vers la page de choix avec la liste des utilisateurs trouvés
      elsif params[:by_name].present? && advisors.many?
        redirect_to annuaire_many_users_path({ advisors: advisors.ids, by_name: params[:by_name] }.merge(form_params))

      # Si il y a un recherche par antenne et pas par nom
      # on redirige vers les utilisateurs de l'antenne
      elsif params[:by_name].empty? && antennes.size == 1
        redirect_to institution_users_path(institution, { antenne_id: advisors.first.antenne }.merge(form_params))

      # Si il y a plusieurs antenne et une seule institution
      # on redirige vers les utilisateurs des antennes
      elsif params[:by_name].empty?
        redirect_to institution_users_path(institution)
      else
        redirect_to annuaire_no_user_path(form_params)
      end
    end

    def many_users
      @advisors = User.where(id: params[:advisors])
    end

    def no_user; end
  end
end
