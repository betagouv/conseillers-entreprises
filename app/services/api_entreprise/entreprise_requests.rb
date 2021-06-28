# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequests
    attr_reader :token, :siren, :connection, :options, :hash

    KEY_CLASSES_MAPPING = {
      entreprises:EntrepriseRequest::Entreprises,
      rcs: EntrepriseRequest::Rcs
    }

    def initialize(token, siren, connection, options = {})
      @token = token
      @siren = siren
      @connection = connection
      @options = options
    end

    def call
      @hash = {data: {}, errors: {}}
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
      errors.join(', ')
    end

    private

    def url_keys
      @url_keys ||= options.fetch(:url_keys)
    end

    def errors
      @errors ||= hash[:errors]
    end
  end
end
