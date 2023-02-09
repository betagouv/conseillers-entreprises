# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match do
  describe 'expert uniqueness for each need' do
    subject(:match) { build :match, need: need, expert: expert }

    let(:need) { create :need }
    let(:expert) { create :expert }
    let(:other_expert) { create :expert }

    context 'another expert matched for the same need' do
      before { create(:match, need: need, expert: other_expert) }

      it { is_expected.to be_valid }
    end

    context 'the same expert matched for the same need' do
      before { create(:match, need: need, expert: expert) }

      it { is_expected.not_to be_valid }
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

  describe 'auto_close_other_pole_emploi_matches' do
    let(:need) { create :need }
    let(:pole_emploi) { create :institution, name: 'Pole Emploi', slug: 'pole-emploi' }
    let!(:match_pe_01) do
      create :match, need: need, status: :quo,
      expert: create(:expert, antenne: create(:antenne, institution: pole_emploi))
    end
    let!(:match_02) do
      create :match, need: need, status: :quo,
      expert: create(:expert, antenne: create(:antenne, institution: institution))
    end
    let!(:match_03) { create :match, need: need, status: :quo }

    context 'pole emploi refusing' do
      let(:institution) { pole_emploi }

      before { match_pe_01.update status: :not_for_me }

      it 'doesnt changes current match status' do
        expect(match_pe_01.reload.status).to eq('not_for_me')
      end

      it 'doesnt change other pole emploi match status' do
        expect(match_02.reload.status).to eq('quo')
      end

      it 'doesnt change other match status' do
        expect(match_03.reload.status).to eq('quo')
      end
    end

    context 'pole emploi taking care' do
      before { match_pe_01.update status: :taking_care }

      context 'with 2 pole_emploi matches' do
        let(:institution) { pole_emploi }

        it 'doesnt changes current match status' do
          expect(match_pe_01.reload.status).to eq('taking_care')
        end

        it 'changes other pole emploi match status' do
          expect(match_02.reload.status).to eq('not_for_me')
        end

        it 'doesnt change other match status' do
          expect(match_03.reload.status).to eq('quo')
        end
      end

      context 'with 1 pole_emploi match' do
        let(:institution) { create :institution }

        it 'doesnt change match status' do
          expect(match_pe_01.reload.status).to eq('taking_care')
        end

        it 'doesnt change other matches status' do
          expect(match_03.reload.status).to eq('quo')
          expect(match_02.reload.status).to eq('quo')
        end
      end
    end
  end

  describe 'defaults' do
    let(:match) { create :match }

    context 'creation' do
      it { expect(match.status).not_to be_nil }
    end

    context 'update' do
      it { expect { match.update status: nil }.to raise_error ActiveRecord::NotNullViolation }
    end
  end

  describe 'scopes' do
    describe 'updated_more_than_five_days_ago' do
      subject { described_class.updated_more_than_five_days_ago }

      let!(:match_updated_two_weeks_ago) { create :match, updated_at: 2.weeks.ago }

      before { create :match, updated_at: 4.days.ago }

      it { is_expected.to match_array [match_updated_two_weeks_ago] }
    end

    describe 'sent' do
      let(:match1) { create :match }
      let(:match2) { create :match }

      subject { described_class.sent }

      before do
        match1.diagnosis.update(step: :completed)
        match2.diagnosis.update(step: :needs)
      end

      it { is_expected.to match_array [match1] }
    end
  end
end
