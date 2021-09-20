module RegionsHelper
  def folder_logo(region_code, key)
    slug, name = find_name_and_slug(region_code)
    path = find_path(key, slug)
    params = { alt: t("logos.#{key}", name: name), class: 'institution_logo' }
    image_tag(path, params) if path
  end

  def prefet_region_logo(region_code)
    folder_logo(region_code, "prefets_regions")
  end

  def region_logo(region_code)
    folder_logo(region_code, "regions")
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
