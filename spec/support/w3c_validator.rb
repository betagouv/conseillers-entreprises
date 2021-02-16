module W3cValidator
  require 'w3c_validators'

  RSpec::Matchers.define :be_valid_html do
    validator = W3CValidators::NuValidator.new
    WebMock.allow_net_connect!
    errors = []
    match do |body|
      validator.validate_text(body)
      errors << validator.results.errors
      # ne prend pas en compte les erreurs CSS pour le moment elle ne sont pas pertinente, peut être trouver un moyen de mieux intégrer le validateur
      errors = errors.flatten.delete_if { |e| e.message == 'CSS: Parse Error.' }
      errors.length == 0
    end
    failure_message do |actual|
      errors.map do |err|
        puts W3cValidator.parse_html_error(err, actual)
      end.join("\n")
    end
  end

  def self.parse_html_error(err, actual)
    separator = "######\n"
    error = /line \d.*/.match err.to_s
    line_number = /line (\d*)/.match(err.to_s)[1].to_i

    sbody = actual.split("\n")
    context = sbody[[line_number - 3,0].max...line_number - 1].join("\n")
    context += "\n>>" + sbody[line_number - 1] + "\n"
    context += sbody[line_number..line_number + 2].join("\n")

    separator + error.to_s + "\n\n" + context + "\n\n"
  end
end
