# frozen_string_literal: true

module Users
  module RegistrationsHelper
    def form_default_values_for_resource(resource)
      %w[first_name last_name institution role phone_number email].each do |attribute|
        string = "default_#{attribute}"
        param = params[string.to_sym]
        resource.send("#{attribute}=", param)
      end
    end
  end
end
