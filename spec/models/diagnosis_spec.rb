# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :diagnosed_needs
    is_expected.to belong_to :visit
    is_expected.to validate_presence_of :visit
    is_expected.to validate_inclusion_of(:step).in_array(Diagnosis::AUTHORIZED_STEPS)
  end

  describe 'acts_as_paranoid' do
    let(:diagnosis) { create :diagnosis }

    before do
      diagnosis.destroy
    end

    it('destroys softly the diagnosis') do
      expect(Diagnosis.all.count).to eq 0
      expect(Diagnosis.only_deleted.count).to eq 1
      expect(Diagnosis.with_deleted.count).to eq 1
    end
  end

  describe 'scopes' do
    describe 'of_siret' do
      subject { Diagnosis.of_siret siret }

      let(:visit) { build :visit, facility: facility }
      let(:facility) { create :facility }
      let(:siret) { facility.siret }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'only one diagnosis' do
        it do
          diagnosis = create :diagnosis, visit: visit

          is_expected.to eq [diagnosis]
        end
      end
    end

    describe 'of_user' do
      subject { Diagnosis.of_user user }

      let(:user) { build :user }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'only one diagnosis' do
        it do
          visit = create :visit, advisor: user
          diagnosis = create :diagnosis, visit: visit

          is_expected.to eq [diagnosis]
        end
      end

      context 'two diagnoses' do
        it do
          visit1 = create :visit, advisor: user
          visit2 = create :visit, advisor: user
          diagnosis1 = create :diagnosis, visit: visit1
          diagnosis2 = create :diagnosis, visit: visit2

          is_expected.to match_array [diagnosis1, diagnosis2]
        end
      end
    end

    describe 'reverse_chronological' do
      subject { Diagnosis.all.reverse_chronological }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'only one diagnosis' do
        it do
          diagnosis = create :diagnosis

          is_expected.to eq [diagnosis]
        end
      end

      context 'two diagnoses' do
        it do
          diagnosis1 = create :diagnosis, created_at: 3.day.ago
          diagnosis2 = create :diagnosis, created_at: 1.day.ago

          is_expected.to eq [diagnosis2, diagnosis1]
        end
      end
    end

    describe 'in progress' do
      subject { Diagnosis.all.in_progress.count }

      context 'no diagnosis' do
        it { is_expected.to eq 0 }
      end

      context 'no diagnosis in_progress' do
        it do
          create :diagnosis, step: 5

          is_expected.to eq 0
        end
      end

      context 'two diagnosis in_progress' do
        it do
          create :diagnosis, step: 5
          create :diagnosis, step: 2
          create :diagnosis, step: 4

          is_expected.to eq 2
        end
      end
    end

    describe 'completed' do
      subject { Diagnosis.all.completed.count }

      context 'no diagnosis' do
        it { is_expected.to eq 0 }
      end

      context 'no diagnosis completed' do
        it do
          create :diagnosis, step: 3

          is_expected.to eq 0
        end
      end

      context 'two diagnosis completed' do
        it do
          create :diagnosis, step: 5
          create :diagnosis, step: 5
          create :diagnosis, step: 4

          is_expected.to eq 2
        end
      end
    end
  end

  describe 'creation_date_localized' do
    it do
      diagnosis = create :diagnosis, created_at: Date.new(2017, 7, 1).to_datetime
      expect(diagnosis.creation_date_localized).to eq '01/07/2017'
    end
  end

  describe 'enrich_with_diagnosed_needs_count' do
    subject(:diagnoses_with_count) { described_class.enrich_with_diagnosed_needs_count diagnoses }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }

    context 'no diagnosed need' do
      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 0 }
    end

    context '2 diagnosed needs' do
      before { create_list :diagnosed_need, 2, diagnosis: diagnosis }

      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2 }
    end

    context '2 diagnosis and 3 needs' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }

      before do
        create_list :diagnosed_need, 2, diagnosis: diagnosis
        create_list :diagnosed_need, 1, diagnosis: other_diagnosis
      end

      it do
        expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2
        expect(diagnoses_with_count.last.diagnosed_needs_count).to eq 1
      end
    end
  end

  describe 'enrich_with_selected_assistances_experts_count' do
    subject(:diagnoses_with_count) { described_class.enrich_with_selected_assistances_experts_count diagnoses }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }
    let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

    context 'no selected assistance expert' do
      it { expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 0 }
    end

    context '2 selected assistances experts' do
      before { create_list :selected_assistance_expert, 2, diagnosed_need: diagnosed_need }

      it { expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 2 }
    end

    context '2 diagnosis and 3 selected assistances experts' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }
      let(:other_diagnosed_need) { create :diagnosed_need, diagnosis: other_diagnosis }

      before do
        create_list :selected_assistance_expert, 2, diagnosed_need: diagnosed_need
        create_list :selected_assistance_expert, 1, diagnosed_need: other_diagnosed_need
      end

      it do
        expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 2
        expect(diagnoses_with_count.last.selected_assistances_experts_count).to eq 1
      end
    end
  end

  describe 'can_be_viewed_by?' do
    subject { diagnosis.can_be_viewed_by?(user) }

    let(:visit) { create :visit, advisor: advisor }
    let(:user) { create :user }
    let!(:diagnosis) { create :diagnosis, visit: visit }

    context 'diagnosis advisor is the user' do
      let(:advisor) { user }

      it { is_expected.to eq true }
    end

    context 'diagnosis advisor is not the user' do
      let(:advisor) { create :user }

      it { is_expected.to eq false }
    end
  end
end
# rubocop:enable Metrics/BlockLength
