module ImagesHelper
  EXTENSIONS = %w[png svg jpg jpeg webp]

  def display_logo(name: "", path: "", extra_params: {})
    return if name.blank?
    slug = name.parameterize
    possible_paths = EXTENSIONS.map{ |e| "#{path}#{slug}.#{e}" }
    path = possible_paths.find{ |possible_path| resolve_asset_path(possible_path, true) }
    params = { alt: name.strip.titleize.capitalize }
    params.merge! extra_params
    image_tag(image_path(path), params) if path
  end

  def landing_and_theme_logos(landing_or_theme)
    logos = landing_or_theme.landing_subjects.map{ |ls| ls.solicitable_institutions.with_solicitable_logo.map(&:logo) }.flatten.uniq
    display_all_logos(logos, 'institutions/')
  end

  def landing_subject_logos(landing_subject)
    logos = landing_subject.solicitable_institutions.with_solicitable_logo.map(&:logo)
    display_all_logos(logos, 'institutions/')
  end

  def display_svg(path)
    Rails.root.join('app', 'assets', 'images', path).open('r') do |file|
      raw file.read
    end
  end

  private

  def display_all_logos(logos, path)
    logos.map { |l| display_logo(name: l.filename, path: path) }.join.html_safe
  end
end
