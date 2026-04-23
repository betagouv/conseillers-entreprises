module PrecomputeFlags
  def self.extended(base)
    base.attr_accessor :has_doublons, :has_relances, :has_similar_abandonned
  end

  def precompute_flags(date_range: 3.weeks.ago..Time.zone.now)
    records = current_scope.to_a
    return records if records.empty?

    emails = records.filter_map(&:email)
    sirets_map = precompute_sirets_per_solicitation(records, emails)
    all_sirets = sirets_map.values.flatten.uniq

    doublons = precompute_doublons(all_sirets, emails)
    relances = precompute_relances(records, all_sirets, emails, date_range)
    abandons = precompute_similar_abandonned(all_sirets, emails)

    records.each do |solicitation|
      sirets = sirets_map[solicitation.id]
      email = solicitation.email
      solicitation.has_doublons = doublons.any? { |other_id, other_siret, other_email| other_id != solicitation.id && (other_email == email || sirets.include?(other_siret)) }
      solicitation.has_relances = relances.any? { |other_id, other_siret, other_email, other_subject_id| other_id != solicitation.id && (other_email == email || sirets.include?(other_siret)) && other_subject_id == solicitation.landing_subject_id }
      solicitation.has_similar_abandonned = abandons.count { |other_id, other_siret, other_email| other_id != solicitation.id && (other_email == email || sirets.include?(other_siret)) } >= 4
    end

    records
  end

  private

  def precompute_sirets_per_solicitation(records, emails)
    facility_sirets = Facility
                        .joins(:company, company: :contacts)
                        .where(contacts: { email: emails })
                        .pluck('contacts.email', :siret)

    records.each_with_object({}) do |solicitation, hash|
      sirets = [solicitation.facility&.siret]
      clean_siret = FormatSiret.clean_siret(solicitation.siret)
      sirets << clean_siret if FormatSiret.siret_is_valid(clean_siret)
      sirets |= facility_sirets.filter_map { |email, siret| siret if email == solicitation.email }
      hash[solicitation.id] = sirets.compact
    end
  end

  def same_companies_scope(all_sirets, all_emails)
    table = Solicitation.arel_table
    same_company = table[:siret].in(all_sirets).or(table[:email].in(all_emails))
    Solicitation.unscoped.where(same_company)
  end

  def precompute_doublons(all_sirets, all_emails)
    same_companies_scope(all_sirets, all_emails)
      .where(status: :in_progress)
      .pluck(:id, :siret, :email)
  end

  def precompute_relances(records, all_sirets, all_emails, date_range)
    landing_subject_ids = records.filter_map(&:landing_subject_id).uniq
    return [] if landing_subject_ids.empty?

    same_companies_scope(all_sirets, all_emails)
      .where(status: :processed, landing_subject_id: landing_subject_ids)
      .where(created_at: date_range)
      .pluck(:id, :siret, :email, :landing_subject_id)
  end

  def precompute_similar_abandonned(all_sirets, all_emails)
    same_companies_scope(all_sirets, all_emails)
      .where(status: :canceled)
      .pluck(:id, :siret, :email)
  end
end
