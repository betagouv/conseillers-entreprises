desc 'Fetch missing code_effectif for Companies and Facilities'
task fetch_companies_effectifs: :environment do
  Company.where(code_effectif: nil)
    .where.not(legal_form_code: "1000")
    .limit(100)
    .find_each do |company|
    puts "Fetching #{company.siren}"

    wrapper = UseCases::SearchCompany.with_siren(company.siren)

    effectif_entreprise = wrapper.entreprise.dig('tranche_effectif_salarie_entreprise', 'code')
    if effectif_entreprise.present?
      company.update(code_effectif: effectif_entreprise)
    end

    siret = wrapper.etablissement_siege['siret']
    effectif_etablissement = wrapper.etablissement_siege.dig('tranche_effectif_salarie_etablissement', 'code')
    if siret.present? && effectif_etablissement.present?
      Facility.where(siret: siret).limit(1).update_all(code_effectif: effectif_etablissement)
    end
  end
end
