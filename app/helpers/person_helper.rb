module PersonHelper
  def person_block_raw(params)
    defaults = { name: nil, prefix: nil, suffix: nil, role: nil, email: nil, phone_number: nil }
    params = defaults.merge!(params)
    render 'person', params
  end

  def person_block(person, extra_params = {})
    return t('person.deleted_person') if person.nil?

    params = {
      name: person.full_name,
      role: detailed_role(person),
      email: person.email,
      phone_number: person.phone_number
    }
    person_block_raw(params.merge(extra_params))
  end

  # Utilisé avec le nouveau design
  def person_infos(person, extra_params = {})
    return t('person.deleted_person') if person.nil?

    params = {
      name: person.full_name,
      role: detailed_role(person),
      email: person.email,
      phone_number: person.phone_number
    }
    person_infos_raw(params.merge(extra_params))
  end

  def person_infos_raw(params)
    defaults = { name: nil, prefix: nil, suffix: nil, role: nil, email: nil, phone_number: nil }
    params = defaults.merge!(params)
    render 'person_infos', params
  end

  private

  def detailed_role(person)
    if defined? person.antenne
      "#{person.role} - #{person.antenne.name}"
    else
      person.role
    end
  end
end
