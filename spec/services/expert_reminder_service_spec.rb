# frozen_string_literal: true

require 'rails_helper'

describe ExpertReminderService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'reminders' do
    subject(:reminders) { described_class.reminders }

    before do
      allow(Need).to receive(:quo_not_taken_after_3_weeks).and_return([need_quo_not_taken])
      allow(Need).to receive(:taken_not_done_after_3_weeks).and_return([need_taken_not_done])
    end

    let(:need_quo_not_taken) { create(:need, matches: matches_quo_not_taken) }
    let(:need_taken_not_done) { create(:need, matches: matches_taken_not_done) }

    context 'experts are different' do
      let(:matches_quo_not_taken) { create_list(:match, 2) }
      let(:matches_taken_not_done) { create_list(:match, 2) }

      it do
        expect(reminders.count).to eq 4
        expect(reminders.values.flat_map(&:values).flatten.count).to eq 4
      end
    end

    context 'expert is the same' do
      let(:expert_skillA) { create :expert_skill, expert: create(:expert) }

      let(:matches_quo_not_taken) { create_list(:match, 2, expert_skill: expert_skillA) }
      let(:matches_taken_not_done) { create_list(:match, 2, expert_skill: expert_skillA) }

      it do
        expect(reminders.count).to eq 1
        expect(reminders.values.flat_map(&:values).flatten.count).to eq 4
      end
    end

    context 'there are no matches' do
      let(:matches_quo_not_taken) { [] }
      let(:matches_taken_not_done) { [] }

      it { expect(reminders).to be_empty }
    end
  end
end
