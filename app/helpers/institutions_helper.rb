module InstitutionsHelper
  include ImagesHelper

  def all_institutions_images
    Institution
      .preload(:logo)
      .national
      .with_home_page_logo
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
