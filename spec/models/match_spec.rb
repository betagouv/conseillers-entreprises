# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosed_need
      # is_expected.to belong_to :assistance_expert  # TODO: We currently have bad data in DB, and cannot validate this
      is_expected.to validate_presence_of :diagnosed_need
    end
  end

  describe 'audited' do
    context 'create' do
      it { expect { create :match }.to change(Audited::Audit, :count).by 1 }
    end

    context 'update status' do
      let!(:match) { create :match }

      it { expect { match.update status: :done }.to change(Audited::Audit, :count).by 1 }
    end

    context 'update attribute other than status' do
      let!(:match) { create :match }

      it do
        expect { match.update assistance_title: 'UPDATE !!' }.not_to change Audited::Audit, :count
      end
    end

    context 'destroy' do
      let!(:match) { create :match }

      it { expect { match.destroy }.to change(Audited::Audit, :count).by 1 }
    end
  end

  describe 'after_update' do
    let(:match) { create :match }

    context 'status is taking_care and going back to quo' do
      before do
        match.update status: :taking_care
        match.update status: :quo
      end

      it 'updates the taken_care_of_at to nil' do
        expect(match.taken_care_of_at).to be_nil
      end

      it 'leaves the closed_at timestamp at nil' do
        expect(match.closed_at).to be_nil
      end
    end

    context 'status is quo and updating to taking_care' do
      before { match.update status: :taking_care }

      it 'updates the taken_care_of_at timestamp' do
        expect(match.taken_care_of_at).not_to be_nil
        expect(match.taken_care_of_at.to_date).to eq Date.today
      end

      it 'leaves the closed_at timestamp at nil' do
        expect(match.closed_at).to be_nil
      end
    end

    context 'status is quo and going back to done' do
      before { match.update status: :done }

      it 'updates the taken_care_of_at timestamp' do
        expect(match.taken_care_of_at).not_to be_nil
        expect(match.taken_care_of_at.to_date).to eq Date.today
      end

      it 'updates the closed_at timestamp' do
        expect(match.closed_at).not_to be_nil
        expect(match.closed_at.to_date).to eq Date.today
      end
    end

    context 'status is done and going back to taking_care' do
      before do
        match.update status: :done
        match.update status: :taking_care
      end

      it 'keeps the taken_care_of_at timestamp' do
        expect(match.taken_care_of_at).not_to be_nil
      end

      it 'updates the closed_at timestamp to nil' do
        expect(match.closed_at).to be_nil
      end
    end
  end

  describe 'assistance expert and relay cannot both be set' do
    subject(:match) { build :match }

    let(:assistance_expert) { create :assistance_expert }
    let(:relay) { create :relay }

    context 'assistance expert and relay cannot both be set' do
      before { match.assistance_expert = assistance_expert }

      it { is_expected.to be_valid }
    end

    context 'assistance expert and relay cannot both be set' do
      before { match.relay = relay }

      it { is_expected.to be_valid }
    end

    context 'assistance expert and relay cannot both be set' do
      before do
        match.assign_attributes assistance_expert: assistance_expert,
                                                     relay: relay
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe 'defaults' do
    let(:match) { create :match, :with_assistance_expert }

    context 'creation' do
      it { expect(match.status).not_to be_nil }
    end

    context 'update' do
      it { expect { match.update status: nil }.to raise_error ActiveRecord::NotNullViolation }
    end
  end

  describe 'scopes' do
    describe 'not_viewed' do
      subject { Match.not_viewed }

      let(:match) { create :match, expert_viewed_page_at: nil }

      before { create :match, expert_viewed_page_at: 2.days.ago }

      it { is_expected.to eq [match] }
    end

    describe 'of_diagnoses' do
      subject { Match.of_diagnoses [diagnosis] }

      let(:diagnosis) { create :diagnosis }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
      let(:match) do
        create :match, :with_assistance_expert, diagnosed_need: diagnosed_need
      end

      before do
        create :diagnosed_need, diagnosis: diagnosis
        create :match, :with_assistance_expert
      end

      it { is_expected.to eq [match] }
    end

    describe 'with_status' do
      let!(:match_with_status_quo) { create :match, status: :quo }
      let!(:match_taken_care_of) { create :match, status: :taking_care }
      let!(:match_with_status_done) { create :match, status: :done }
      let!(:match_not_for_expert) { create :match, status: :not_for_me }

      it do
        expect(Match.with_status(:quo)).to eq [match_with_status_quo]
        expect(Match.with_status(:taking_care)).to eq [match_taken_care_of]
        expect(Match.with_status(:done)).to eq [match_with_status_done]
        expect(Match.with_status(:not_for_me)).to eq [match_not_for_expert]
      end
    end

    describe 'updated_more_than_five_days_ago' do
      subject { Match.updated_more_than_five_days_ago }

      let!(:match_updated_two_weeks_ago) { create :match, updated_at: 2.weeks.ago }

      before { create :match, updated_at: 4.days.ago }

      it { is_expected.to match_array [match_updated_two_weeks_ago] }
    end
  end
end
