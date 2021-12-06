module PersonHelper
  def person_block_raw(params)
    defaults = { name: nil, prefix: nil, suffix: nil, job: nil, email: nil, phone_number: nil }
    params = defaults.merge!(params)
    render 'application/person', params
  end

  def person_block(person, extra_params = {})
    return t('person.deleted_person') if person.nil?

    params = {
      name: person.full_name,
      job: detailed_job(person),
      email: person.email,
      phone_number: person.phone_number
    }
    person_block_raw(params.merge(extra_params))
  end

  private

  def detailed_job(person)
    return unless defined?(person.job)

    if defined?(person.antenne)
      [person.job, person.antenne.name].compact_blank.join(" - ")
    else
      person.job
    end
  end
end
