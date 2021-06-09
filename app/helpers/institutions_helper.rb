module InstitutionsHelper
  include ImagesHelper

  def all_institutions_images(region_code)
    Institution
      .where(code_region: [region_code, nil])
      .ordered_logos
      .pluck(:name)
      .map(&:parameterize).uniq
      .map { institution_image(_1) }
      .join.html_safe
  end

  def institution_image(name, with_host = false)
    params = { class: 'institution_logo' }
    display_image({ name: name, path: "institutions/", extra_params: params, with_host: with_host })
  end
end
