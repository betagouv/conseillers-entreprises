module ApiConsumption::Models
  class Base
    include ActiveModel::Model

    # A renseigner pour chaque model
    def self.fields
      []
    end

    def initialize(params = {})
      params = params.with_indifferent_access # accepter les strings et les sym, pour faciliter l'usage
      self.class.fields.each do |key|
        dynamically_create_attr_accessor(key, params[key])
      end
    end

    private

    def dynamically_create_attr_accessor(attribute_name, attribute_value)
      self.class.send(:define_method, "#{attribute_name}=".to_sym) do |value|
        instance_variable_set("@" + attribute_name.to_s, value)
      end

      self.class.send(:define_method, attribute_name.to_sym) do
        instance_variable_get("@" + attribute_name.to_s)
      end

      self.send("#{attribute_name}=".to_sym, attribute_value) # if params.key?(key)
    end
  end
end
