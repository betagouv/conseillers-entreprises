module RegionsHelper
  def region_image(region_code)
    slug = I18n.t(region_code, scope: 'regions_codes_to_slugs')
    name = I18n.t(region_code, scope: 'regions_codes_to_libelles')
    possible_paths = "regions/#{slug}.png", "regions/#{slug}.svg", "regions/#{slug}.jpg"
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: t('logos.prefet_region', name: name), class: 'institution_logo' }
    image_tag(path, params) if path
  end
end
