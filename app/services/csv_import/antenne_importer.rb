module CsvImport
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
      attributes[:institution] = Institution.find_by(name: attributes[:institution])
    end

    def find_instance(attributes)
      Antenne.find_or_initialize_by(institution: attributes[:institution], name: attributes[:name])
    end
  end
end
