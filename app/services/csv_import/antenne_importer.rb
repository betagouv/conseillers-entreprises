module CsvImport
  ## UserImporter needs an :institution to be passed in the options
  class AntenneImporter < BaseImporter
    def mapping
      @mapping ||=
        %i[institution name insee_codes manager_full_name manager_email manager_phone]
          .index_by{ |k| Antenne.human_attribute_name(k) }
    end

    def check_headers(headers)
      headers.filter_map do |header|
        UnknownHeaderError.new(header) unless mapping.include? header.squish
      end
    end

    def preprocess(attributes)
      attributes.transform_values!(&:squish)
      attributes[:insee_codes] = FormatInseeCodes.normalize(attributes[:insee_codes]) if attributes[:insee_codes].present?
      attributes[:institution] = Institution.find_by(name: attributes[:institution]) || @options[:institution]
    end

    def find_instance(attributes)
      antenne = Antenne.flexible_find_or_initialize(attributes[:institution], attributes[:name])
      attributes.delete(:name)
      return antenne, attributes
    end

    def postprocess(antenne, row)
      attributes = row_to_attributes(row)
      create_manager(antenne, attributes)
    end

    def create_manager(antenne, attributes)
      attributes[:manager_email] = attributes[:manager_email].strip.downcase if attributes[:manager_email].present?
      return if attributes[:manager_email].blank?
      manager = User.find_or_initialize_by(email: attributes[:manager_email])
      manager.update(
        antenne: antenne,
        role: 'antenne_manager',
        job: I18n.t('attributes.manager'),
        full_name: attributes[:manager_full_name],
        phone_number: attributes[:manager_phone]
      )
      return CsvImportError::ManagerError.new(manager.errors.full_messages.to_sentence) unless manager.valid?
    end
  end
end
