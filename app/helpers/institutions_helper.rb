module InstitutionsHelper
  include ImagesHelper

  def all_institutions_images(region)
    Institution
      .where(region_name: [region, '', nil])
      .ordered_logos
      .pluck(:name)
      .map(&:parameterize).uniq
      .map { institution_image(_1) }
      .join.html_safe
  end

  def institution_image(name, extra_params = {})
    params = { class: 'institution_logo' }
    display_image({ name: name, path: "institutions/", extra_params: params })
  end
end
