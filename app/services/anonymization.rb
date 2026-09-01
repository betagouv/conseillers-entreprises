module Anonymization
  module_function

  def anonymized_marker = I18n.t('anonymization.data')

  # Batch-anonymize all the records that can contain identifying information.
  # Used for development copies of the production DB.
  #
  # - Experts and users: name, phone, email
  #   Keep the email and name fields consistent between users and their single-user expert
  #
  # - Contacts and Solicitations: name, phone, email
  #   Keep the email and name fields consistent between related solicitations and contacts
  #
  # - Facilities and solicitations: siret, company name, siren
  #   Keep the siret field consistent between related solicitations and facilities
  #
  # - Text descriptions in Solicitations, CompanySatisfactions, Solicitations, Companies
  def suppress_all
    suppress_experts_and_users
    suppress_contacts_and_solicitations
    suppress_facilities_and_solicitations
    suppress_descriptions_and_comments

    ApplicationRecord.connection.execute "VACUUM FULL ANALYZE"
  end

  def suppress_experts_and_users
    task("Suppress users") do
      User.not_deleted.where.not(id: User.admin)
        .update_all("email=CONCAT('anon-user-', id, '@anon'), full_name=CONCAT('anon-user-', id), phone_number=NULL, encrypted_password='', current_sign_in_ip=NULL, last_sign_in_ip=NULL")
    end
    task("Suppress single-user experts") do
      Expert.where(id: Expert.not_deleted.with_one_user).where.not(id: Expert.joins(:users).merge(User.admin))
        .joins(:users).update_all("email=users.email, phone_number=NULL, full_name=CONCAT('anon-user-', users.id)")
    end
    task("Suppress team experts") do
      Expert.not_deleted.where.not(id: Expert.with_one_user).where.not(id: Expert.joins(:users).merge(User.admin))
        .update_all("email=CONCAT('anon-team-', id, '@anon'), full_name=CONCAT('anon-team-', id), phone_number=NULL")
    end
  end

  def suppress_contacts_and_solicitations
    task("Suppress solicitations with contacts") do
      Solicitation.where.not(full_name: anonymized_marker).where.not(email: nil)
        .joins("INNER JOIN contacts ON solicitations.email = contacts.email")
        .in_batches_with_progress(of: 5000).update_all("email=CONCAT('contact-', contacts.id, '@anon'), full_name=CONCAT('contact-', contacts.id), phone_number=NULL")
    end
    task("Suppress contacts") do
      Contact.where.not(full_name: anonymized_marker).where.not(email: nil)
        .joins("INNER JOIN contacts contacts2 ON contacts.email = contacts2.email")
        .in_batches_with_progress(of: 5000).update_all("email=CONCAT('contact-', contacts2.id, '@anon'), full_name=CONCAT('contact-', contacts2.id), phone_number=NULL")
    end
    task("Suppress other solicitations") do
      Solicitation.where.not(full_name: anonymized_marker).where.not(email: nil).where.not("email LIKE '%@anon'")
        .in_batches_with_progress(of: 5000).update_all("email=CONCAT('solicitation-', id, '@anon'), full_name=CONCAT('solicitation-', id), phone_number=NULL")
    end
  end

  def suppress_facilities_and_solicitations
    task("Suppress solicitations with facilities") do
      Solicitation.where.not("solicitations.siret LIKE 'facility-%'").where.not(siret: [nil, ''])
        .joins("INNER JOIN facilities ON solicitations.siret = facilities.siret")
        .in_batches_with_progress(of: 5000).update_all("siret=CONCAT('facility-', facilities.id)")
    end
    task("Suppress facilities") do
      Facility.where.not("siret LIKE 'facility-%'").where.not(siret: [nil, ''])
        .in_batches_with_progress(of: 5000).update_all("siret=CONCAT('facility-', id)")
    end
    task("Suppress solicitations without facility") do
      Solicitation.where.not("siret LIKE 'facility-%'").where.not(siret: [nil, ''])
        .in_batches_with_progress(of: 5000).update_all("siret=CONCAT('solicitation-', id)")
    end
    task("Suppress companies") do
      Company.where.not(name: anonymized_marker)
        .in_batches_with_progress(of: 5000).update_all("name=CONCAT('company-', id), siren=CONCAT('company-', id)")
    end
  end

  def suppress_descriptions_and_comments
    task("Suppress descriptions and comments") do
      anonymized_text = I18n.t("anonymization.paragraphs")
      Solicitation.where.not(description: [nil, "", anonymized_text]).update_all(description: anonymized_text)
      CompanySatisfaction.where.not(comment: [nil, "", anonymized_text]).update_all(comment: anonymized_text)
      Diagnosis.where.not(content: [nil, "", anonymized_text]).update_all(content: anonymized_text)
      Feedback.where.not(description: [nil, "", anonymized_text]).update_all(description: anonymized_text)
    end
  end

  ## Helpers
  #
  def ensure_can_anonymize!
    raise "Do not anonymize production data" unless Rails.env.development? || ENV['TEST_ANONYMIZATION']
  end

  def task(name, &block)
    ensure_can_anonymize!

    puts name
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '0'")
      yield
    end
    puts "Done"
  end
end
