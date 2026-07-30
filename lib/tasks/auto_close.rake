desc 'Automatically close old subjects with in-progress matches'
task auto_close: :environment do
  last_year = 1.year.ago.all_year
  matches_still_in_progress = Match.in_progress.where(created_at: last_year)
  needs_still_in_progress = Need.in_progress.where(created_at: last_year)

  puts "#{needs_still_in_progress.size} besoins créées en #{last_year.begin.year} encore en cours ('quo'/'taking_care')"
  puts needs_still_in_progress.ids
  puts "#{matches_still_in_progress.size} MER créées en #{last_year.begin.year} encore en cours ('quo'/'taking_care')"
  puts matches_still_in_progress.ids

  errors = []
  # matches_still_in_progress.each do |match|
  #   match.update!(status: :done_no_help)
  # rescue => e
  #   errors << [match, e]
  # end

  puts "#{matches_still_in_progress.size - errors.size} MER mis à jour en 'done_no_help'"
  puts "Erreurs : #{errors.inspect}" if errors.any?

  needs_still_in_progress = Need.joins(:matches).where(matches: matches_still_in_progress).in_progress

  puts "#{needs_still_in_progress.size} besoins encore 'en cours' après clôture"
  puts "(à vérifier au cas par cas : normal seulement si un AUTRE match du besoin est encore actif)"
  puts needs_still_in_progress.ids
end
