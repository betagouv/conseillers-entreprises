# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
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
        let!(:diagnosis) { create :diagnosis, visit: visit }

        it { is_expected.to eq [diagnosis] }
      end

      context 'two diagnosis' do
        let!(:diagnosis_1) { create :diagnosis, visit: visit }
        let!(:diagnosis_2) { create :diagnosis, visit: visit }

        it { is_expected.to eq [diagnosis_1, diagnosis_2] }
      end
    end
  end
end
