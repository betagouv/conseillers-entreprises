module ActiveAdmin
  module Inputs
    # `f.input :expert, as: :ajax_select, data: { url:, search_fields: }`
    class AjaxSelectInput < ::Formtastic::Inputs::SelectInput
      include AjaxSelectCore

      def collection_from_association
        limited_collection(super)
      end

      def selected_records
        return [] unless object.respond_to?(method)

        Array.wrap(object.public_send(method)).compact
      end
    end
  end
end
