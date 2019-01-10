module InstitutionsHelper
  def all_institutions_images
    Institution.order(:name).pluck(:name).map(&method(:institution_image)).join.html_safe
  end

  def institution_image(name, extra_params = {})
    slug = name.parameterize
    possible_paths = "institutions/#{slug}.png", "institutions/#{slug}.svg", "institutions/#{slug}.jpg"
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: name, title: name, class: 'institution_logo' }
    params.merge! extra_params
    image_tag(path, params) if path
  end
end
