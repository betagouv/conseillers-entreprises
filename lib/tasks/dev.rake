# frozen_string_literal: true

# Misc tasks to help project developers
namespace :dev do
  desc 'This tasks adds random data'
  task sample_data: :environment do
    local_office = LocalOffice.create! name: Faker::Company.name

    expert = Expert.new full_name: Faker::Name.name,
                        email: Faker::Internet.email
    expert.assign_attributes role: Faker::Job.title, local_office: local_office
    expert.save!

    category = Category.create! label: Faker::Lorem.sentence
    Question.create! label: Faker::Lorem.sentence, category: category

    2.times do
      local_office_id = LocalOffice.all.pluck(:id).sample
      expert_id = Expert.all.pluck(:id).sample
      question_id = Question.all.pluck(:id).sample
      Assistance.create! title: Faker::Lorem.sentence,
                         local_office_id: local_office_id,
                         expert_id: expert_id,
                         question_id: question_id
    end
  end
end
