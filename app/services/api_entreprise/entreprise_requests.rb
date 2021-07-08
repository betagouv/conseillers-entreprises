# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequests
    attr_reader :token, :siren, :connection, :options, :hash

    KEY_CLASSES_MAPPING = {
      entreprises: EntrepriseRequest::Entreprises,
      rcs: EntrepriseRequest::Rcs,
      rm: EntrepriseRequest::Rm
    }

    def initialize(token, siren, connection, options = {})
      @token = token
      @siren = siren
      @connection = connection
      @options = options
    end

    def call
      @hash = { data: {}, errors: {} }
      url_keys.each_with_object(@hash) do |key, hash|
        response = KEY_CLASSES_MAPPING[key].new(token, siren, connection, options).response
        if response.success?
          hash[:data].deep_merge! response.data
        else
          hash[:errors][key] = response.error_message
        end
      end
      self
    end

    def success?
      errors.empty?
    end

    def data
      @data ||= hash[:data]
    end

    def error_message
      errors.values.join(', ')
    end

    private

    # Par défaut, on appelle toutes les url (cas le + fréquent)
    def url_keys
      options[:url_keys] || [:entreprises, :rcs, :rm]
    end

    def errors
      @errors ||= hash[:errors]
    end
  end
end
