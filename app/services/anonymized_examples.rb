# frozen_string_literal: true

module AnonymizedExamples
  module_function

  def self.data
    @data ||= YAML.load_file(Rails.root.join("config", "data", "anonymized_examples.yaml"))
  end

  def self.solicitations
    solicitations = Solicitation.where(id: data.keys).includes(:landing_subject, :needs)
    solicitations.each do |solicitation|
      solicitation.description = data[solicitation.id]
      solicitation.freeze
    end
    solicitations
  end
end
