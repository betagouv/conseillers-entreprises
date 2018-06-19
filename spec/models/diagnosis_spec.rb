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

  describe 'archive' do
    let(:diagnosis) { create :diagnosis }

    before do
      diagnosis.archive!
    end

    it('archives the diagnosis') do
      expect(Diagnosis.all.count).to eq 1
      expect(Diagnosis.only_active.count).to eq 0
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
      subject { Diagnosis.reverse_chronological }

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
      subject { Diagnosis.in_progress.count }

      context 'no diagnosis' do
        it { is_expected.to eq 0 }
      end

      context 'no diagnosis in_progress' do
        it do
          create :diagnosis, step: Diagnosis::LAST_STEP

          is_expected.to eq 0
        end
      end

      context 'two diagnosis in_progress' do
        it do
          create :diagnosis, step: Diagnosis::LAST_STEP
          create :diagnosis, step: 2
          create :diagnosis, step: 4

          is_expected.to eq 2
        end
      end
    end

    describe 'completed' do
      subject { Diagnosis.completed.count }

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
          create :diagnosis, step: Diagnosis::LAST_STEP
          create :diagnosis, step: Diagnosis::LAST_STEP
          create :diagnosis, step: 4

          is_expected.to eq 2
        end
      end
    end

    describe 'in_territory' do
      subject { Diagnosis.in_territory territory }

      let(:territory) { create :territory }
      let(:facility) { create :facility, city_code: 59_001 }
      let(:visit) { create :visit, facility: facility }
      let!(:diagnosis) { create :diagnosis, visit: visit }

      context 'with territory cities' do
        before { create :territory_city, territory: territory, city_code: 59_001 }

        it { is_expected.to eq [diagnosis] }
      end

      context 'without territory city' do
        it { is_expected.to eq [] }
      end
    end

    describe 'available_for_expert' do
      subject { Diagnosis.available_for_expert(expert) }

      let(:expert) { create :expert }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'one diagnosis' do
        let(:diagnosis) { create :diagnosis }
        let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
        let(:assistance_expert) { create :assistance_expert, expert: expert }

        before do
          create :match, diagnosed_need: diagnosed_need, assistance_expert: assistance_expert
        end

        it { is_expected.to eq [diagnosis] }
      end
    end
  end

  describe 'creation_date_localized' do
    it do
      diagnosis = create :diagnosis, created_at: Date.new(2017, 7, 1).to_datetime
      expect(diagnosis.creation_date_localized).to eq '01/07/2017'
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
