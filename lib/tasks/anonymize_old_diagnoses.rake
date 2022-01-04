task anonymize_old_diagnoses: :environment do
  # Anonymize diagnoses created between 3 years ago and 3 years less 1 week
  # Prevent big requests
  start_date = 3.years.ago
  end_date = (3.years - 8.days).ago
  anonymization(start_date, end_date)
end

task anonymize_all_old_diagnoses: :environment do
  # Anonymize diagnoses created more than 3 years ago
  start_date = 100.years.ago
  end_date = 3.years.ago
  anonymization(start_date, end_date)
end

def anonymization(start_date, end_date)
  anonymized = I18n.t('attributes.anonymized')
  diagnoses = Diagnosis.where(created_at: start_date..end_date)
  diagnoses.each do |diagnosis|
    diagnosis&.visitee&.update(email: nil, full_name: anonymized, phone_number: anonymized)
    diagnosis&.solicitation&.update(email: nil, full_name: anonymized, phone_number: anonymized, siret: nil)
    next if diagnosis.company.diagnoses.pluck(:created_at).max > end_date
    diagnosis.company.update(name: anonymized, siren: nil)
    diagnosis.company.facilities.each { |facility| facility.update(siret: nil) }
  end
end
