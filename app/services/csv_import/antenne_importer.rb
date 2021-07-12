module CsvImport
  ## UserImporter needs an :institution to be passed in the options
  class AntenneImporter < BaseImporter
    def mapping
      @mapping ||=
        %i[institution name insee_codes]
          .index_by{ |k| Antenne.human_attribute_name(k) }
    end

    def check_headers(headers)
      headers.map do |header|
        UnknownHeaderError.new(header) unless mapping.include? header
      end.compact
    end

    def preprocess(attributes)
      attributes[:institution] = Institution.find_by(name: attributes[:institution]) || @options[:institution]
    end

    def find_instance(attributes)
      antenne = Antenne.flexible_find_or_initialize(attributes[:institution], attributes[:name])
      attributes.delete(:name)
      return antenne, attributes
    end
  end
end
