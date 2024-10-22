namespace :rattrapage_api_rne do
  desc 'relaunch diagnosis if missed'
  task relaunch_search_facility: :environment do
    set_params
    puts '## Relance des analyses des sollicitations'
    facilities_to_update = no_nature_activite_facilities
    companies_to_update = no_nature_activite_companies
    puts "Etablissement sans nature activite des #{@days_count} derniers jours : #{facilities_to_update.count}"
    puts "Entreprise sans nature activite des #{@days_count} derniers jours : #{companies_to_update.count}"
    facilities_to_update.find_each do |facility|
      UseCases::SearchFacility.with_siret_and_save(facility.siret)
    end
    puts "Etablissements restant sans nature activite : #{no_nature_activite_facilities.count}"
    puts "Entreprises restant sans nature activite : #{no_nature_activite_companies.count}"
  end

  task all: %i[relaunch_search_facility]
end

desc 'Rattrapage analyse'
task rattrapage_api_rne: %w[rattrapage_api_rne:all]

def set_params
  @days_count = 2
  @start_at = @days_count.days.ago
  @end_at = Time.zone.now
end

def no_nature_activite_companies
  Company
    .where(created_at: @start_at..@end_at)
    .where.not(siren: nil)
    .where(forme_exercice: nil)
end

def no_nature_activite_facilities
  Facility
    .where(created_at: @start_at..@end_at)
    .where.not(siret: nil)
    .where(nature_activites: [])
end
