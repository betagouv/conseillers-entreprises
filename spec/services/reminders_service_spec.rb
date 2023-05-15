# frozen_string_literal: true

require 'rails_helper'
describe RemindersService do
  describe 'create_reminders_registers' do
    describe 'baskets' do
      create_experts_for_reminders

      before { described_class.create_reminders_registers }

      # Multiple expects en un bloc pour gagner du temps d'exécution
      describe 'create correct baskets' do
        it do
          expect(RemindersRegister.many_pending_needs_basket.map(&:expert)).to contain_exactly(expert_with_many_old_quo_matches)
          expect(RemindersRegister.medium_pending_needs_basket.map(&:expert)).to contain_exactly(expert_with_medium_old_quo_matches)
          expect(RemindersRegister.one_pending_need_basket.map(&:expert)).to contain_exactly(expert_with_one_quo_match_1, expert_with_one_old_quo_match)
        end
      end
    end

    describe 'categories' do
      create_registers_for_reminders

      before { described_class.create_reminders_registers }
      # Multiple expects en un bloc pour gagner du temps d'exécution

      describe 'creates correct categories' do
        it do
          expect(RemindersRegister.current_remainder_category.map(&:expert)).to contain_exactly(expert_remainder, expert_input_processed, expert_remainder_category)
          expect(RemindersRegister.current_input_category.map(&:expert)).to contain_exactly(expert_input, expert_remainder_not_processed)
          expect(RemindersRegister.current_output_category.map(&:expert)).to contain_exactly(expert_output_not_seen, old_expert_output_not_seen, expert_input_to_output)
          expect(RemindersRegister.current_expired_category.map(&:expert)).to contain_exactly(expert_remainder_to_expired)
        end
      end
    end
  end
end
