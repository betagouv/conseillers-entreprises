module RecordExtensions
  module HumanAttributeValue
    # Like :human_attribute_name, but for enum values.
    #
    extend ActiveSupport::Concern
    class_methods do
      # Fetches  the i18n key at
      # `activerecord.attributes.<klass>/<enum_names>.<value>`
      # @enum_name is pluralized.
      # @value is converted to the string value (e.g. from `0` to `"in_progress"`) \if necessary.
      # @options:
      #  - :context lets you specify another sets of locales for the same enum.
      #  - :disable_cast avoid converting @value; casting requires a DB connection, so this is sometimes needed
      #
      # @example:
      # > Solicitation.human_attribute_value(:status, :canceled)
      # => "Annulée" # I18n.t('activerecord.attributes.solicitation/statuses.canceled')
      #
      # @example:
      # > Solicitation.human_attribute_value(:status, 2)
      # => "Annulée" # I18n.t('activerecord.attributes.solicitation/statuses.canceled')
      #
      # @example:
      # > Solicitation.human_attribute_value(:status, :canceled, context: :action)
      # => "Annuler" # I18n.t('activerecord.attributes.solicitation/statuses/action.canceled')
      #
      # @example:
      # > Solicitation.human_attribute_value(:status, :canceled, context: :done, count: 2)
      # => "annulées" # I18n.t('activerecord.attributes.solicitation/statuses/done.canceled.other')
      def human_attribute_value(enum_name, value, options = {})
        unless options.delete(:disable_cast)
          value = attribute_types[enum_name.to_s].cast(value)
        end
        context = options.delete(:context)
        enum_i18n_scope = [enum_name.to_s.pluralize, context].compact.join('/')
        human_attribute_name("#{enum_i18n_scope}.#{value}", options)
      end

      # Returns a hash of the enum values => localized text
      # @options:
      #  - raw_values: use the database integer values rather than the enum constants
      #
      # @example:
      # > Solicitation.human_attribute_values(:status)
      # => {"in_progress"=>"Reçue", "processed"=>"Clôturée", "canceled"=>"Annulée"}
      #
      # @example:
      # > Solicitation.human_attribute_values(:status, context: :done)
      # => {"in_progress"=>"réouverte", "processed"=>"clôturée", "canceled"=>"annulée"}
      def human_attribute_values(enum_name, options = {})
        mapping = self.send(enum_name.to_s.pluralize)
        enum_values = if options.delete(:raw_values)
          mapping.values
        else
          mapping.keys
        end
        enum_values.index_with{ |value| human_attribute_value(enum_name, value, options.dup) }
      end
    end

    # Instance method
    # @example:
    # > Solicitation.last.human_attribute_value(:status)
    # => "Reçue"
    def human_attribute_value(enum_name, options = {})
      self.class.human_attribute_value(enum_name, self.send(enum_name), options)
    end
  end
end
