# frozen_string_literal: true

task clone_visits_for_diagnoses: :environment do
  visits = Visit.all
  visits.each do |visit|
    diagnoses = Diagnosis.where(visit_id: visit.id)
    next if diagnoses.count < 2
    puts "Visit ##{visit.id} with #{diagnoses.count} diagnoses"
    diagnoses.each_with_index do |diagnosis, index|
      next if index.zero?
      cloned_visit = visit.dup
      cloned_visit.save!
      puts "Updating diagnosis ##{diagnosis.id} with a clone of visit ##{visit.id}"
      diagnosis.update! visit_id: cloned_visit.id
    end
  end
end
