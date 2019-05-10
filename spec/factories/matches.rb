# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    transient do
      expert { create :expert }
    end

    need
    expert_skill { create(:expert_skill, expert: expert) }
  end
end
