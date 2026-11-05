class SolicitationExamples
  def self.data
    @data ||= YAML.load_file(Rails.root.join("config", "data", "solicitation_examples.yml")).deep_symbolize_keys
  end

  def initialize(landing_subject)
    @landing_subject = landing_subject
  end

  def any?
    cases.any?
  end

  def title
    entry[:title]
  end

  def cases
    entry.fetch(:cases, [])
  end

  def description
    institutions = @landing_subject.solicitable_institutions_names
    key = institutions.any? ? 'description_with_institutions' : 'description'
    I18n.t(key, scope: 'solicitations.examples', count: institutions.size, institutions: institutions.to_sentence, solutions: entry[:solutions])
  end

  private

  def entry
    @entry ||= self.class.data.fetch(@landing_subject.slug.to_sym, {})
  end
end
