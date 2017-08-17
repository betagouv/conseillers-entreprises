# frozen_string_literal: true

task set_diagnoses_step_at_2: :environment do
  diagnoses = Diagnosis.all
  diagnoses.each do |diagnosis|
    diagnosis.update step: 2
  end
end
