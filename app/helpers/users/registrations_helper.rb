# frozen_string_literal: true

module Users
  module RegistrationsHelper
    def form_default_values_for_resource(resource)
      %w[full_name role phone_number email].each do |attribute|
        string = "default_#{attribute}"
        param = params[string.to_sym]
        resource.send("#{attribute}=", param)
      end
    end

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
