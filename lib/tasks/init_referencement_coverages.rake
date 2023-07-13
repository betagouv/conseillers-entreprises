# A supprimer une fois l'initialisation faite

desc 'init referencement coverages'
task init_referencement_coverages: :environment do
  Antenne.territorial_level_regional.each do |antenne|
    InitReferencementCoverages.new(antenne).delay(queue: :low_priority).call
  end
end
