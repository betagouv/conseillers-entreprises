# frozen_string_literal: true

require 'rails_helper'
describe RemindersService do
  describe 'create_reminders_registers' do
    describe 'baskets' do
      create_experts_for_reminders

      before { described_class.create_reminders_registers }

      describe 'many_pending_needs category' do
        it { expect(RemindersRegister.many_pending_needs_basket.map(&:expert)).to match_array [expert_with_many_old_quo_matches] }
      end

      describe 'medium_pending_needs category' do
        it { expect(RemindersRegister.medium_pending_needs_basket.map(&:expert)).to match_array [expert_with_medium_old_quo_matches] }
      end

      describe 'one_pending_need category' do
        it { expect(RemindersRegister.one_pending_need_basket.map(&:expert)).to match_array [expert_with_one_quo_match_1, expert_with_one_old_quo_match] }
      end
    end

    describe 'current week category' do
      # Expert deja présent la semaine passée et avec encore des besoins en attentes
      let(:expert_remainder) { create :expert_with_users }
      let!(:rg_expert_remainder) { create :reminders_register, created_at: 1.week.ago, expert: expert_remainder, category: :input }
      let!(:expert_remainder_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_remainder } }
      # Expert entrant dans les relances
      let(:expert_input) { create :expert_with_users, reminders_registers: [] }
      let!(:expert_input_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_input } }
      # Expert sortant
      let(:expert_output) { create :expert_with_users }
      let!(:rg_expert_output) { create :reminders_register, created_at: 1.week.ago, expert: expert_output }
      let!(:expert_output_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :done, expert: expert_output } }

      before { described_class.create_reminders_registers }

      describe 'remainder category' do
        it { expect(RemindersRegister.current_remainder_category.map(&:expert)).to match_array [expert_remainder] }
      end

      describe 'input category' do
        it { expect(RemindersRegister.current_input_category.map(&:expert)).to match_array [expert_input] }
      end

      describe 'output category' do
        it { expect(RemindersRegister.current_output_category.map(&:expert)).to match_array [expert_output] }
      end
    end
  end
end
