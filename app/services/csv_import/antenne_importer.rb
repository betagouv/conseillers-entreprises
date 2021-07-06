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
      institution_antennes = Antenne.where(institution: attributes[:institution])
      antenne = institution_antennes.where('lower(name) = ?', attributes[:name].squish.downcase).first
      antenne ||= Antenne.new(institution: attributes[:institution], name: attributes[:name].strip)
      antenne
    end
  end
end
