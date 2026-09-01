module HomeEmphasisHelper
  def path_to_emphasis_item(item, **query_params)
    case item
    when Landing
      landing_path(item, **query_params)
    end
  end
end
