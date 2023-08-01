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
    display_logo(name: name, path: "institutions/", extra_params: params)
  end
end
