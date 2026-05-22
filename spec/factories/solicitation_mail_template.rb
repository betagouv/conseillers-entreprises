FactoryBot.define do
  factory :solicitation_mail_template do
    sequence(:email_type) { |n| Solicitation::GENERIC_EMAILS_TYPES.flatten.without(:bad_quality)[n % 17].to_s }
    body_html { '<p>Contenu de test</p>' }
  end
end
