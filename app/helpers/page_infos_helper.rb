# frozen_string_literal: true

module PageInfosHelper
  def collection_count(collection)
    size = collection.size.is_a?(Hash) ? collection.size.keys.count : collection.size
    collection_name = size == 1 ? collection.model_name.human : collection.model_name.human.pluralize
    t('helpers.page_infos.collection_count_html', size: size, name: collection_name)
  end
end
