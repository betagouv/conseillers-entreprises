FactoryBot.define do
  factory :profil_picture do
    user { nil }
    filename { Faker::File.file_name }
  end
end
