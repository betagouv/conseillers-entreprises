module RegionsHelper
  def prefet_region_logo(region_code)
    slug, name = find_name_and_slug(region_code)
    possible_paths = "prefets_regions/#{slug}.png", "prefets_regions/#{slug}.svg", "prefets_regions/#{slug}.jpg"
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: t('logos.prefet_region', name: name), class: 'institution_logo' }
    image_tag(path, params) if path
  end
  private

  def find_name_and_slug(region_code)
    slug = I18n.t(region_code, scope: 'regions_codes_to_slugs')
    name = I18n.t(region_code, scope: 'regions_codes_to_libelles')
    [slug, name]
  end
end
