# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :question
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :experts
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :question
    end
  end

  describe 'scopes' do
    describe 'of_diagnosis' do
      subject { Assistance.of_diagnosis diagnosis }

      let(:diagnosis) { create :diagnosis }
      let(:question) { create :question }

      before { create :diagnosed_need, diagnosis: diagnosis, question: question }

      context 'one assistance' do
        let!(:assistance) { create :assistance, question: question }

        it { is_expected.to eq [assistance] }
      end

      context 'several assistances' do
        let!(:assistance) { create :assistance, question: question }
        let!(:assistance2) { create :assistance, question: question }

        it { is_expected.to match_array [assistance, assistance2] }
      end

      context 'no assistance' do
        it { is_expected.to be_empty }
      end
    end
  end
end
