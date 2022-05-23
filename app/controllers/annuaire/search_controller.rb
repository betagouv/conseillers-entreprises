module Annuaire
  class SearchController < ApplicationController
    def search
      institution = Institution.find_by(slug: params[:institution_slug])
      advisors = User.joins(antenne: :institution)
        .where(antenne: { institution: institution })
        .where('full_name ILIKE ?', "%#{params[:advisor_search]}%")
      antennes = advisors.map(&:antenne).uniq
      if params[:advisor_search].empty?
        redirect_to institution_users_path(institution)
      elsif antennes.many? || advisors.many?
        redirect_to many_users_path(advisors: advisors.ids, advisor_search: params[:advisor_search])
      else
        redirect_to institution_users_path(institution, advisor: advisors.first.id, antenne_id: antennes.first.id, advisor_search: params[:advisor_search])
      end
    end

    def many_users
      @advisors = User.where(id: params[:advisors])
    end
  end
end
