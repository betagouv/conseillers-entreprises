# frozen_string_literal: true

class About::TemoignagesExpertsController < PagesController
  def index
    @temoignages = TemoignagesExperts.data
  end

  def show
    @key = params[:id]
    @temoignage = TemoignagesExperts.data.fetch(@key.to_sym) { not_found }
    @new_solicitation_path = new_solicitation_path(landing_slug: 'accueil', landing_subject_slug: @temoignage.landing_subject, mtm_campaign: 'temoignages_experts', mtm_kwd: @temoignage.mtm_kwd)
  end
end
