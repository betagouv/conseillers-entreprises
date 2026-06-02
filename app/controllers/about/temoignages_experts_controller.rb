# frozen_string_literal: true

class About::TemoignagesExpertsController < PagesController
  def index
    @temoignages = temoignages
    @institutions_names = Institution.where(slug: @temoignages.values.pluck('institution')).pluck(:slug, :name).to_h
  end

  def show
    @temoignage_key = params[:id]
    @data = temoignages.fetch(@temoignage_key) { not_found }
    @new_solicitation_path = new_solicitation_path(landing_slug: 'accueil', landing_subject_slug: @data['landing_subject'], mtm_campaign: 'temoignages_experts', mtm_kwd: @data['mtm_kwd'])
  end

  def temoignages
    YAML.load_file("#{Rails.root.join('config', 'data', 'temoignages_experts.yml')}", permitted_classes: [Date])
  end
end
