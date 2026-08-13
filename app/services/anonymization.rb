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
    return unless Rails.env.development?

    suppress_experts_and_users
    suppress_contacts_and_solicitations
    suppress_facilities_and_solicitations
    suppress_descriptions_and_comments

    ApplicationRecord.connection.execute "VACUUM FULL ANALYZE"
  end

  def suppress_experts_and_users
    return unless Rails.env.development?

    User.not_deleted.where.not(id: User.admin)
      .update_all("email=CONCAT('anon-user-', id, '@anon'), full_name=CONCAT('anon-user-', id), phone_number=NULL, encrypted_password='', current_sign_in_ip=NULL, last_sign_in_ip=NULL")
    Expert.where(id: Expert.not_deleted.with_one_user).where.not(id: Expert.joins(:users).merge(User.admin))
      .joins(:users).update_all("email=users.email, phone_number=NULL, full_name=CONCAT('anon-user-', users.id)")
    Expert.not_deleted.where.not(id: Expert.with_one_user).where.not(id: Expert.joins(:users).merge(User.admin))
      .update_all("email=CONCAT('anon-team-', id, '@anon'), full_name=CONCAT('anon-team-', id), phone_number=NULL")
  end

  def suppress_contacts_and_solicitations
    return unless Rails.env.development?

    Solicitation.where.not(full_name: anonymized_marker).where.not(email: nil)
      .joins("INNER JOIN contacts ON solicitations.email = contacts.email")
      .in_batches(of: 5000).update_all("email=CONCAT('contact-', contacts.id, '@anon'), full_name=CONCAT('contact-', contacts.id), phone_number=NULL")

    Contact.where.not(full_name: anonymized_marker).where.not(email: nil)
      .joins("INNER JOIN contacts contacts2 ON contacts.email = contacts2.email")
      .in_batches(of: 5000).update_all("email=CONCAT('contact-', contacts2.id, '@anon'), full_name=CONCAT('contact-', contacts2.id), phone_number=NULL")

    Solicitation.where.not(full_name: anonymized_marker).where.not(email: nil).where.not("email LIKE '%@anon'")
      .in_batches(of: 5000).update_all("email=CONCAT('solicitation-', id, '@anon'), full_name=CONCAT('solicitation-', id), phone_number=NULL")
  end

  def suppress_facilities_and_solicitations
    return unless Rails.env.development?

    Solicitation.where.not("solicitations.siret LIKE 'facility-%'").where.not(siret: [nil, ''])
      .joins("INNER JOIN facilities ON solicitations.siret = facilities.siret")
      .in_batches(of: 5000).update_all("siret=CONCAT('facility-', facilities.id)")

    Facility.where.not("siret LIKE 'facility-%'").where.not(siret: [nil, ''])
      .update_all("siret=CONCAT('facility-', id)")

    Solicitation.where.not("siret LIKE 'facility-%'").where.not(siret: [nil, ''])
      .in_batches(of: 5000).update_all("siret=CONCAT('solicitation-', id)")

    Company.where.not(name: anonymized_marker)
      .update_all("name=CONCAT('company-', id), siren=CONCAT('company-', id)")
  end

  def suppress_descriptions_and_comments
    return unless Rails.env.development?

    anonymized_text = I18n.t("anonymization.paragraphs")
    Solicitation.where.not(description: [nil, "", anonymized_text]).update_all(description: anonymized_text)
    CompanySatisfaction.where.not(comment: [nil, "", anonymized_text]).update_all(comment: anonymized_text)
    Diagnosis.where.not(content: [nil, "", anonymized_text]).update_all(content: anonymized_text)
    Feedback.where.not(description: [nil, "", anonymized_text]).update_all(description: anonymized_text)
  end
end
