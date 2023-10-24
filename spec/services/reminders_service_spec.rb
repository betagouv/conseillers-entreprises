# frozen_string_literal: true

require 'rails_helper'
describe RemindersService do
  describe 'create_reminders_registers' do
    describe 'baskets' do
      create_experts_for_reminders

      before { described_class.new.create_reminders_registers }

      # Multiple expects en un bloc pour gagner du temps d'exécution
      describe 'create correct baskets' do
        it do
          # expect(RemindersRegister.many_pending_needs_basket.map(&:expert)).to contain_exactly(expert_with_many_old_quo_matches)
          # expect(RemindersRegister.medium_pending_needs_basket.map(&:expert)).to contain_exactly(expert_with_medium_old_quo_matches)
          expect(RemindersRegister.one_pending_need_basket.map(&:expert)).to contain_exactly(expert_with_one_quo_match_1, expert_with_one_old_quo_match)
        end
      end
    end

    describe 'categories' do
      create_registers_for_reminders

      before { described_class.new.create_reminders_registers }

      # Multiple expects en un bloc pour gagner du temps d'exécution
      describe 'creates correct categories' do
        it do
          expect(RemindersRegister.current_remainder_category.map(&:expert)).to contain_exactly(expert_remainder, expert_input_processed, expert_remainder_category)
          expect(RemindersRegister.current_input_category.map(&:expert)).to contain_exactly(expert_input, expert_remainder_not_processed)
          expect(RemindersRegister.current_output_category.map(&:expert)).to contain_exactly(expert_output_not_seen, old_expert_output_not_seen, expert_input_to_output)
          expect(RemindersRegister.current_expired_need_category.map(&:expert)).to contain_exactly(expert_remainder_to_expired)
        end
      end
    end

    describe 'expired_needs' do
      let!(:expert) { create :expert_with_users }

      context 'new entry in expired_needs' do
        let!(:rg_inputs_processed) { create :reminders_register, expert: expert, category: :input, processed: true, run_number: 1 }
        let!(:expired_needs) { travel_to(46.days.ago) { create_list :match, 3, status: :quo, expert: expert } }

        before { described_class.new.create_reminders_registers }

        it { expect(RemindersRegister.current_expired_need_category.map(&:expert)).to contain_exactly(expert) }
      end

      context 'already in expired needs and not seen' do
        let!(:rg_expired_needs_not_processed) { create :reminders_register, expert: expert, category: :expired_needs, processed: false, run_number: 1 }
        let!(:expired_needs) { travel_to(46.days.ago) { create_list :match, 3, status: :quo, expert: expert } }

        before { described_class.new.create_reminders_registers }

        it { expect(RemindersRegister.current_expired_need_category.map(&:expert)).to contain_exactly(expert) }
      end

      context 'already in expired needs and seen' do
        let!(:rg_expired_needs_processed) { create :reminders_register, expert: expert, category: :expired_needs, processed: true, run_number: 1 }
        let!(:expired_needs) { travel_to(46.days.ago) { create_list :match, 3, status: :quo, expert: expert } }

        before { described_class.new.create_reminders_registers }

        it { expect(RemindersRegister.current_expired_need_category.map(&:expert)).to be_empty }
      end
    end

    describe 'one_pending_need' do
      let!(:expert) { create :expert_with_users }
      let!(:new_match) { create :match, status: :quo, expert: expert }
      let!(:ancient_match) { create :match, status: status, created_at: created_at, sent_at: created_at, expert: expert }

      context 'when has an old done match' do
        let(:status) { :done }
        let(:created_at) { 4.months.ago }

        before { described_class.new.create_reminders_registers }

        it do
          expect(RemindersRegister.current_input_category.map(&:expert)).to contain_exactly(expert)
          expect(expert.reminders_registers.last.basket).to eq("one_pending_need")
        end
      end

      context 'when has an old quo match' do
        let(:status) { :quo }
        let(:created_at) { 4.months.ago }

        before { described_class.new.create_reminders_registers }

        it do
          expect(RemindersRegister.current_input_category.map(&:expert)).to contain_exactly(expert)
          expect(expert.reminders_registers.last.basket).to eq("one_pending_need")
        end
      end

      context 'when has a recent quo match' do
        let(:status) { :quo }
        let(:created_at) { 1.month.ago }

        before { described_class.new.create_reminders_registers }

        it do
          expect(RemindersRegister.current_input_category.map(&:expert)).to be_empty
          expect(expert.reminders_registers).to be_empty
        end
      end

      context 'when has an old done and a recent quo match' do
        let(:status) { :quo }
        let(:created_at) { 1.month.ago }
        let!(:oldest_match) { create :match, status: :done, created_at: 4.months.ago, sent_at: 4.months.ago, expert: expert }

        # si on remonte le create_reminders_registers, oldest_match n'est pas créé
        before { described_class.new.create_reminders_registers }

        it do
          expect(RemindersRegister.current_input_category.map(&:expert)).to be_empty
          expect(expert.reminders_registers).to be_empty
        end
      end
    end
  end
end
