module ActiveAdmin
  module Inputs
    # Shared behaviour of the :ajax_select input, for both the form and the filter
    # variants defined alongside this module.
    #
    # Replaces the activeadmin-ajax_filter gem: it pins activeadmin < 4, and its
    # selectize frontend is jQuery based, which cannot survive the removal of
    # jQuery in v4. Only the options this application actually uses are supported,
    # namely `data: { url:, search_fields: }`.
    #
    # Options are served by the plain ActiveAdmin index action, which already
    # answers JSON and already understands Ransack params: no dedicated endpoint.
    module AjaxSelectCore
      # How many options are rendered server side. Anything beyond that is fetched
      # by app/assets/javascripts/admin/ajax_select.js as the user types.
      PRELOADED_OPTIONS = 20

      def input_html_options
        super.merge(
          'data-ajax-select': '',
          'data-url': url,
          'data-search-param': search_param,
          'data-label-field': label_field,
          'data-limit': PRELOADED_OPTIONS
        ).merge(localized_data)
      end

      # Reuses the wording already shown by the slim-select widgets of the public app
      def localized_data
        {
          'data-placeholder-text': I18n.t('helpers.slim_select.placeholder_text'),
          'data-search-placeholder': I18n.t('helpers.slim_select.search_placeholder'),
          'data-search-text': I18n.t('helpers.slim_select.search_text'),
          'data-searching-text': I18n.t('helpers.slim_select.searching_text')
        }
      end

      # Listing every associated record would make pages such as /admin/matches
      # unusable, so only a slice is rendered, plus whatever is already selected.
      # Leaving the latter out would silently clear the association on save.
      def limited_collection(scope)
        return scope if scope.nil?

        (selected_records + scope.limit(PRELOADED_OPTIONS).to_a).uniq
      end

      private

      def ajax_data
        options[:data] || {}
      end

      def search_fields
        ajax_data[:search_fields] ||
          raise(ArgumentError, 'an :ajax_select input requires data: { search_fields: [...] }')
      end

      # Ransack predicate matching any of the searchable fields, eg. "name_or_slug_cont"
      def search_param
        "#{search_fields.map { |field| field.to_s.tr('.', '_') }.join('_or_')}_cont"
      end

      # Attribute of the JSON payload used as the visible label of an option
      def label_field
        search_fields.first
      end

      def url
        target = ajax_data[:url]
        target.is_a?(Symbol) ? Rails.application.routes.url_helpers.public_send(target) : target
      end
    end
  end
end
