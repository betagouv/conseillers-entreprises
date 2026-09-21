module ActiveAdmin
  module Inputs
    module Filters
      # `filter :expert, as: :ajax_select, data: { url:, search_fields: }`
      class AjaxSelectInput < SelectInput
        include AjaxSelectCore

        def collection_from_association
          limited_collection(super)
        end

        def pluck_column
          klass.reorder("#{method} asc").limit(PRELOADED_OPTIONS).distinct.pluck(method)
        end

        # Ransack exposes the currently applied value under the input name,
        # eg. "institution_id_eq", so the active filter keeps showing its label.
        def selected_records
          return [] if reflection.nil?

          ids = Array.wrap(object.try(input_name)).compact_blank
          ids.any? ? reflection.klass.where(id: ids).to_a : []
        end
      end
    end
  end
end
