module CsvImport
  ## UserImporter needs an :institution to be passed in the options
  class AntenneImporter < BaseImporter
    def mapping
      @mapping ||=
        %i[institution name communes_codes epcis_codes departements_codes region_codes manager_full_name manager_email manager_phone]
          .index_by{ |k| Antenne.human_attribute_name(k) }
    end

    def check_headers(headers)
      headers.filter_map do |header|
        UnknownHeaderError.new(header) unless mapping.include? header.squish
      end
    end

    def preprocess(attributes)
      attributes.transform_values!(&:squish)
      attributes[:communes_codes] = FormatInseeCodes.normalize(attributes[:communes_codes]) if attributes[:communes_codes].present?
      attributes[:institution] = Institution.find_by(name: attributes[:institution]) || @options[:institution]
    end

    def find_instance(attributes)
      antenne = Antenne.flexible_find_or_initialize(attributes[:institution], attributes[:name])
      return antenne, {}
    end

    def postprocess(antenne, row)
      begin
        create_manager(antenne, manager_attributes(row))
        import_territories(antenne, territories_attributes(row))
        antenne
      rescue => e
        CsvImport::PostprocessError.new("Erreur lors du post-traitement de l'antenne : #{e.message}")
      end
    end

    def create_manager(antenne, attributes)
      if attributes[:manager_email].present?
        attributes[:manager_email] = attributes[:manager_email].strip.downcase
      else
        return antenne
      end
      manager = User.find_or_initialize_by(email: attributes[:manager_email])
      manager.update(
        antenne: antenne,
        job: I18n.t('attributes.manager'),
        full_name: attributes[:manager_full_name],
        phone_number: attributes[:manager_phone]
      ) if manager.new_record?
      if manager.persisted? && antenne.managers.exclude?(manager)
        antenne.managers << manager
      else
        # Adds manager so that validations raise error if needed
        antenne.advisors << manager
      end
      antenne
    end

    private

    def manager_attributes(row)
      attributes = row_to_attributes(row)
      attributes.slice(:manager_full_name, :manager_email, :manager_phone)
    end

    def territories_attributes(row)
      attributes = row_to_attributes(row)
      attributes.slice(:communes_codes, :epci_codes, :departements_codes, :region_codes)
    end
  end
end
