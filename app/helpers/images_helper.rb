module ImagesHelper
  EXTENSIONS = %w[png svg jpg jpeg]

  def display_image(name: "", path: "", extra_params: {})
    return if name.blank?
    slug = name.parameterize
    possible_paths = EXTENSIONS.map{ |e| "#{path}#{slug}.#{e}" }
    path = possible_paths.find{ |possible_path| resolve_asset_path(possible_path, true) }
    params = { alt: name.strip.titleize.capitalize }
    params.merge! extra_params
    image_tag(image_path(path), params) if path
  end

  def landing_theme_logos(landing_theme)
    logos = landing_theme.landing_subjects.collect(&:logos).flatten.uniq.sort_by(&:name)
    display_all_logos(logos, 'institutions/')
  end

  def landing_subject_logos(landing_subject)
    logos = landing_subject.logos
    display_all_logos(logos, 'institutions/')
  end

  private

  def display_all_logos(logos, path)
    logos.map { |l| display_image(name: l.filename, path: path) }.join.html_safe
  end
end
