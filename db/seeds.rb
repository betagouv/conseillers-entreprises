# frozen_string_literal: true

if User.find_by(email: "a@a.a").blank?
  antenne = Antenne.first
  User.create!(
    email: "a@a.a",
    password: "1234567",
    is_admin: true,
    phone_number: "0612345678",
    role: "Admin",
    full_name: "Edith Piaf",
    antenne: antenne,
    experts: [antenne.experts.first]
  )
  p "Admin created"
end
