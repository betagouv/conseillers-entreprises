module Annuaire
  class SearchController < ApplicationController
    def search
      institution = Institution.find_by(slug: params[:institution_slug])
      advisors = [
        :by_institution,
        :by_name
      ].inject(User.not_deleted) do |relation, filter|
        next relation unless params[filter].present?

        relation.send(filter, params[filter])
      end
      antennes = advisors.collect(&:antenne).uniq
      # si il y a un seul utilisateur de trouvé
      # On affiche l'utilisateur au sein de son antenne
      if advisors.count == 1
        advisor = advisors.first
        redirect_to institution_users_path(advisor.institution, antenne_id: advisor.antenne)

      # Si il y a un paramètre pour la recherche par nom et plusieurs utilisateurs
      # On redirige vers la page de choix avec la liste des utilisateurs trouvés
      elsif params[:by_name].present? && advisors.many?
        redirect_to many_users_path(advisors: advisors.ids, by_name: params[:by_name])

      # Si il y a plusieurs utilisateur et une seul antenne
      # on redirige vers les utilisateurs de l'antenne
      elsif advisors.many? && antennes.count == 1
        redirect_to institution_users_path(advisors.first.institution, antenne_id: advisors.first.antenne)

      # Si il y a plusieurs antenne et une seule institution
      # on redirige vers les utilisateurs de l'institution
      elsif antennes.many?
        redirect_to institution_users_path(advisors.first.institution)
      else
      end
    end

    def many_users
      @advisors = User.where(id: params[:advisors])
    end
  end
end
