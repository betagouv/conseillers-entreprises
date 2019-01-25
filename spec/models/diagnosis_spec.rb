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

  describe 'can_be_viewed_by?' do
    subject { diagnosis.can_be_viewed_by?(user) }

    let(:visit) { create :visit, advisor: advisor }
    let(:user) { create :user }
    let!(:diagnosis) { create :diagnosis, visit: visit }

    context 'user is the diagnosis advisor' do
      let(:advisor) { user }

      it { is_expected.to eq true }
    end

    context 'user is unrelated' do
      let(:advisor) { create :user }

      it { is_expected.to eq false }
    end
  end
end
# rubocop:enable Metrics/BlockLength
