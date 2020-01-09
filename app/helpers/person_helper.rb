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
      role: person.full_role,
      email: person.email,
      phone_number: person.phone_number
    }
    person_block_raw(params.merge(extra_params))
  end
end
