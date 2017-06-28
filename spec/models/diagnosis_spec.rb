# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :diagnosed_needs
    is_expected.to belong_to :visit
    is_expected.to validate_presence_of(:visit)
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

      context 'two diagnosis' do
        it do
          diagnosis1 = create :diagnosis, visit: visit
          diagnosis2 = create :diagnosis, visit: visit

          is_expected.to match_array [diagnosis1, diagnosis2]
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
