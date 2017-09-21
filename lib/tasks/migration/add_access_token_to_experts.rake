# frozen_string_literal: true

task add_access_token_to_experts: :environment do
  Expert.all.each do |expert|
    expert.generate_access_token!
    expert.save
  end
end
