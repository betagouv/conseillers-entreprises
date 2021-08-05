module CsvImport
  ## UserImporter needs an :institution to be passed in the options
  class AntenneImporter < BaseImporter
    def mapping
      @mapping ||=
        %i[institution name insee_codes manager_full_name manager_email manager_phone]
          .index_by{ |k| Antenne.human_attribute_name(k) }
    end

    def check_headers(headers)
      headers.map do |header|
        UnknownHeaderError.new(header) unless mapping.include? header.squish
      end.compact
    end

    def preprocess(attributes)
      attributes[:institution] = Institution.find_by(name: attributes[:institution]) || @options[:institution]
      attributes[:manager_full_name] = attributes[:manager_full_name]&.squish
      attributes[:manager_email] = attributes[:manager_email]&.squish
      attributes[:manager_phone] = attributes[:manager_phone]&.squish
    end

    def find_instance(attributes)
      antenne = Antenne.flexible_find_or_initialize(attributes[:institution], attributes[:name])
      attributes.delete(:name)
      return antenne, attributes
    end
  end
end
