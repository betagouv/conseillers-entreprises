module ImagesHelper
  EXTENSIONS = %w[png svg jpg jpeg]

  def display_image(name: "", path: "", extra_params: {}, with_host: false)
    slug = name.parameterize
    possible_paths = EXTENSIONS.map{ |e| "#{path}#{slug}.#{e}" }
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: name.strip.titleize.capitalize }
    params.merge! extra_params
    if with_host && path.present?
      image_tag(image_url(path, host: root_url), params)
    elsif path.present?
      image_tag(path, params)
    end
  end
end
