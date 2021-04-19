module ImagesHelper
  EXTENSIONS = %w[png svg jpg jpeg]

  def display_image(name: "", path: "", extra_params: {})
    slug = name.parameterize
    possible_paths = EXTENSIONS.map{ |e| "#{path}#{slug}.#{e}" }
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: name }
    params.merge! extra_params
    image_tag(path, params) if path
  end
end
