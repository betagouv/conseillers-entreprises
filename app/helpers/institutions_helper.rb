module InstitutionsHelper
  include ImagesHelper

  def all_institutions_images
    Institution
      .preload(:logo)
      .where(code_region: nil)
      .ordered_logos
      .map{ |i| i.logo&.filename }
      .uniq
      .map { institution_image(_1) }
      .join.html_safe
  end

  def institution_image(name, extra_params = {})
    params = { class: 'institution-logo' }
    display_image(name: name, path: "institutions/", extra_params: params)
  end

  def antennes_count(institution)
    if session[:annuaire_region_id].present?
      institution.antennes_in_region(session[:annuaire_region_id]).human_count
    else
      institution.not_deleted_antennes.human_count
    end
  end

  def advisors_count(institution)
    if session[:annuaire_region_id].present?
      institution.advisors_in_region(session[:annuaire_region_id]).human_count
    else
      institution.advisors.human_count
    end
  end
end
