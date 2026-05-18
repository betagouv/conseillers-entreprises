FactoryBot.define do
  factory :solicitation_mail_template do
    sequence(:email_type) { |n| "email_type_#{n}" }
    body_html { '<p>Contenu de test</p>' }
  end
end
