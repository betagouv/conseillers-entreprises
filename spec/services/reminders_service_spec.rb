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

    describe 'categories' do
      create_registers_for_reminders

      before do
        described_class.create_reminders_registers
        expert_input_processed.reminders_registers.last.update(processed: true)
      end

      describe 'remainder category' do
        it { expect(RemindersRegister.current_remainder_category.map(&:expert)).to match_array [expert_remainder, expert_input_processed, expert_remainder_category] }
      end

      describe 'input category' do
        it { expect(RemindersRegister.current_input_category.map(&:expert)).to match_array [expert_input, expert_remainder_not_processed] }
      end

      describe 'output category' do
        it { expect(RemindersRegister.current_output_category.map(&:expert)).to match_array [expert_output_not_seen, old_expert_output_not_seen, expert_input_to_output] }
      end
    end
  end
end
