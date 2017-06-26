# frozen_string_literal: true

task create_facilities_from_visits: :environment do
  visits = Visit.all
  visits.each do |visit|
    company = ApiEntrepriseService.fetch_company_with_siren(visit.company.siren)
    facility = UseCases::SearchFacility.with_siret_and_save(company['entreprise']['siret_siege_social'])
    visit.update facility: facility
  end
end
