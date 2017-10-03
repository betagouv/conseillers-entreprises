# frozen_string_literal: true

task fill_facility_naf_and_company_legal_form: :environment do
  Facility.where(naf_code: nil).each do |facility|
    UseCases::SearchFacility.with_siret_and_save(facility.siret)
  end
end
