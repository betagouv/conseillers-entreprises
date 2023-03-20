module ApiConsumption::Models
  class FacilityAutocomplete::ApiEntreprise < FacilityAutocomplete::Base
    def company
      @company ||= ApiConsumption::Models::Company::ApiEntreprise.new(entreprise)
    end

    def facility
      @facility ||= ApiConsumption::Models::Facility::ApiEntreprise.new(etablissement)
    end

    def nombre_etablissements_ouverts
      1
    end
  end
end
