module DiagnosisCreation
  extend ActiveSupport::Concern

  class_methods do
    def create_without_siret(insee_code, params)
      company = Company.create!(name: params['name'])
      commune = Commune.find_or_create_by insee_code: insee_code
      Facility.create! company: company, commune: commune, readable_locality: "#{params['postal_code']} #{params['city']}"
    end
  end
end
