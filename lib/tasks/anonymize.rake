namespace :anonymize do
  task batch_anonymize_data: :environment do
    start_date = 100.years.ago
    end_date = 3.months.ago
    p "begin batch_anonymize_data - #{I18n.l(Time.zone.now, format: :hours)}"
    Company.where(created_at: start_date..end_date).in_batches.update_all(name: anonymized, siren: nil)
    CompanySatisfaction.where(created_at: start_date..end_date).in_batches.update_all(comment: anonymized)
    Contact.where(created_at: start_date..end_date).in_batches.update_all(email: nil, phone_number: anonymized, full_name: anonymized)
    Diagnosis.where(created_at: start_date..end_date).in_batches.update_all(content: anonymized)
    Facility.where(created_at: start_date..end_date).in_batches.update_all(siret: nil)
    Feedback.where(created_at: start_date..end_date).in_batches.update_all(description: anonymized)
    Need.where(created_at: start_date..end_date).in_batches.update_all(content: anonymized)
    Solicitation.where(created_at: start_date..end_date).in_batches.update_all(email: nil, phone_number: anonymized, full_name: anonymized, siret: nil, description: anonymized)
    Expert.active.where(updated_at: start_date..end_date).in_batches.update_all(email: 'anonymized@gouv.fr', phone_number: anonymized, full_name: anonymized)
    User.active.where.not(id: User.admin).where(updated_at: start_date..end_date).in_batches.update_all(email: 'anonymized@gouv.fr', phone_number: anonymized, full_name: anonymized, current_sign_in_ip: nil, last_sign_in_ip: nil)
    p "end batch_anonymize_data - #{I18n.l(Time.zone.now, format: :hours)}"
  end

  task pseudonymize_data: :environment do
    start_date = 3.months.ago
    end_date = Time.zone.now
    p "begin pseudonymize_data - #{I18n.l(Time.zone.now, format: :hours)}"
    p "Company (#{Company.where(created_at: start_date..end_date).size}) #{I18n.l(Time.zone.now, format: :hours)}"
    Company.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(name: Faker::Company.name, siren: Faker::Company.french_siren_number) }
    p "CompanySatisfaction (#{CompanySatisfaction.where(created_at: start_date..end_date).size}) - #{I18n.l(Time.zone.now, format: :hours)}"
    CompanySatisfaction.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(comment: Faker::Lorem.paragraph) }
    p "Contact (#{Contact.where(created_at: start_date..end_date).size})- #{I18n.l(Time.zone.now, format: :hours)}"
    Contact.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(email: Faker::Internet.email, phone_number: Faker::PhoneNumber.phone_number, full_name: Faker::Name.name) }
    p "Diagnosis (#{Diagnosis.where(created_at: start_date..end_date).size}) - #{I18n.l(Time.zone.now, format: :hours)}"
    Diagnosis.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(content: Faker::Lorem.paragraph) }
    p "Facility (#{Facility.where(created_at: start_date..end_date).size}) - #{I18n.l(Time.zone.now, format: :hours)}"
    Facility.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(siret: Faker::Company.french_siret_number) }
    p "Feedback (#{Feedback.where(created_at: start_date..end_date).size}) - #{I18n.l(Time.zone.now, format: :hours)}"
    Feedback.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(description: Faker::Lorem.paragraph) }
    p "Solicitation (#{Solicitation.where(created_at: start_date..end_date).size}) - #{I18n.l(Time.zone.now, format: :hours)}"
    Solicitation.where(created_at: start_date..end_date).find_each{ |record| record.update_columns(email: Faker::Internet.email, phone_number: Faker::PhoneNumber.phone_number, full_name: Faker::Name.name, siret: Faker::Company.french_siret_number, description: Faker::Lorem.paragraph) }

    updated_experts_id = []
    users = User.active.where.not(id: User.admin).where(updated_at: start_date..end_date)
    p "User count : #{users.size} - start: #{I18n.l(Time.zone.now, format: :hours)}"
    users.find_each do |record|
      name = Faker::Name.name
      phone_number = Faker::PhoneNumber.phone_number
      email = Faker::Internet.email
      personal_experts = record.personal_skillsets.active.presence || record.experts.active.where(full_name: record.full_name).or(record.experts.active.where(email: record.email))
      personal_experts.update_all(email: email, phone_number: phone_number, full_name: name) if personal_experts.any?
      record.update_columns(email: email, phone_number: phone_number, full_name: name, current_sign_in_ip: Faker::Internet.ip_v4_address, last_sign_in_ip: Faker::Internet.ip_v4_address)
      updated_experts_id << personal_experts.pluck(:id)
    end
    p "Treated Experts count : #{updated_experts_id.flatten.uniq.size}"

    remaining_experts = Expert.active
      .where(updated_at: start_date..end_date)
      .where.not(id: updated_experts_id.flatten.uniq)
    p "Remaining Experts count : #{remaining_experts.size}  - start: #{I18n.l(Time.zone.now, format: :hours)}"
    remaining_experts.find_each{ |record| record.update_columns(email: Faker::Internet.email, phone_number: Faker::PhoneNumber.phone_number, full_name: Faker::Team.name) }
    p "end pseudonymize_data - #{I18n.l(Time.zone.now, format: :hours)}"
  end

  def anonymize_diagnoses(start_date, end_date)
    diagnoses = Diagnosis.where(created_at: start_date..end_date)
    diagnoses.each do |diagnosis|
      diagnosis&.visitee&.update(email: nil, full_name: anonymized, phone_number: anonymized)
      diagnosis&.solicitation&.update(email: nil, full_name: anonymized, phone_number: anonymized, siret: nil)
      next if diagnosis.company.diagnoses.pluck(:created_at).max > end_date
      diagnosis.company.update(name: anonymized, siren: nil)
      diagnosis.company.facilities.each { |facility| facility.update(siret: nil) }
    end
  end

  def anonymized
    I18n.t('attributes.anonymized')
  end

  task all: %i[batch_anonymize_data pseudonymize_data]
end
