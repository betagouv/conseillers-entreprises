# frozen_string_literal: true

# Misc tasks to help project developers
namespace :dev do
  desc 'This tasks adds random data'
  task sample_data: :environment do
    institution = Institution.create! name: Faker::Company.name

    expert = Expert.new first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email
    expert.assign_attributes role: Faker::Job.title, institution: institution
    expert.save!

    category = Category.create! label: Faker::Lorem.sentence
    Question.create! label: Faker::Lorem.sentence, category: category

    2.times do
      institution_id = Institution.all.pluck(:id).sample
      expert_id = Expert.all.pluck(:id).sample
      question_id = Question.all.pluck(:id).sample
      Assistance.create! title: Faker::Lorem.sentence, institution_id: institution_id, expert_id: expert_id, question_id: question_id
    end
  end
end
