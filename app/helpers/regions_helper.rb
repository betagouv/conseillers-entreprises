module RegionsHelper
  def prefet_region_logo(region_code)
    slug, name = find_name_and_slug(region_code)
    path = find_path("prefets_regions", slug)
    params = { alt: t('logos.prefet_region', name: name), class: 'institution_logo' }
    image_tag(path, params) if path
  end

  def region_logo(region_code)
    slug, name = find_name_and_slug(region_code)
    path = find_path("regions", slug)
    params = { alt: t('logos.region', name: name), class: 'institution_logo' }
    image_tag(path, params) if path
  end

  private

  def find_name_and_slug(region_code)
    slug = I18n.t(region_code, scope: 'regions_codes_to_slugs')
    name = I18n.t(region_code, scope: 'regions_codes_to_libelles')
    [slug, name]
  end

  def find_path(base_path, slug)
    extensions = %w[png svg jpg jpeg]
    possible_paths = extensions.map{ |e| "#{base_path}/#{slug}.#{e}" }
    possible_paths.find{ |path| resolve_asset_path(path, true) }
  end
end
