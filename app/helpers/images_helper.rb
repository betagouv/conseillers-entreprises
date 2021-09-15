module ImagesHelper
  EXTENSIONS = %w[png svg jpg jpeg]

  def display_image(name: "", path: "", extra_params: {})
    slug = name.parameterize
    possible_paths = EXTENSIONS.map{ |e| "#{path}#{slug}.#{e}" }
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: name.strip.titleize.capitalize }
    params.merge! extra_params
    image_tag(image_path(path), params) if path
  end

  def landing_theme_logos(landing_theme)
    logos = landing_theme.landing_subjects.collect(&:logos).flatten.uniq
    display_all_logos(logos)
  end

  def landing_subject_logos(landing_subject)
    logos = landing_subject.logos
    display_all_logos(logos)
  end

  private

  def display_all_logos(logos)
    logos.map { |l| display_image({ name: l.slug, path: 'institutions/' }) }.join.html_safe
  end
end
