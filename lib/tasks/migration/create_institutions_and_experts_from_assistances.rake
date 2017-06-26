# frozen_string_literal: true

task create_institutions_and_experts_from_assistances: :environment do
  user_ids = []

  assistances = Assistance.all
  assistances.each do |assistance|
    institution = Institution.find_or_create_by name: assistance.company.name, email: assistance.company.email, phone_number: assistance.company.phone_number
    user = assistance.user
    user_ids << user.id
    user_hash = { first_name: user.first_name, last_name: user.last_name, institution: institution }
    user_hash.merge!(email: user.email, phone_number: user.phone_number, role: user.role)
    expert = Expert.find_or_create_by user_hash
    assistance.update institution: institution, expert: expert
  end

  user_ids.uniq!
  User.where(id: user_ids, current_sign_in_at: nil).destroy_all
end
