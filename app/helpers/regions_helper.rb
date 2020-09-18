module RegionsHelper
  def region_image(region)
    slug = region&.parameterize
    possible_paths = "regions/#{slug}.png", "regions/#{slug}.svg", "regions/#{slug}.jpg"
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: "logo préfet région #{region}", title: "Préfet région #{region}", class: 'institution_logo' }
    image_tag(path, params) if path
  end
end
