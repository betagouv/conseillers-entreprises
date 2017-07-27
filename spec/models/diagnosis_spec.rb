# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :diagnosed_needs
    is_expected.to belong_to :visit
    is_expected.to validate_presence_of :visit
    is_expected.to validate_inclusion_of(:step).in_array(Diagnosis::AUTHORIZED_STEPS)
  end

  describe 'scopes' do
    describe 'of_visit' do
      subject { Diagnosis.of_visit visit }

      let(:visit) { build :visit }

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

    describe 'limited' do
      subject { Diagnosis.all.limited.count }

      context 'no diagnosis' do
        it { is_expected.to eq 0 }
      end

      context 'two diagnoses' do
        it do
          create_list :diagnosis, 16

          is_expected.to eq 15
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
end
