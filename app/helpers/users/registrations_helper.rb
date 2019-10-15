# frozen_string_literal: true

module Users
  module RegistrationsHelper
    def new_registration_params(params)
      hash = {}
      %w[full_name role phone_number email].each do |attribute|
        string = "default_#{attribute}"
        hash[string.to_sym] = params[attribute.to_sym]
      end
      hash
    end
  end
end
