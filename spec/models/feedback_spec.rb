require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :need
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:need)
        is_expected.to validate_presence_of(:description)
      end
    end
  end

  describe 'can_be_modified_by?' do
    subject { feedback.can_be_modified_by?(expert) }

    let(:feedback) { create :feedback }
    let(:expert) { create :expert }

    context 'expert is the expert of the match' do
      before { feedback.expert = expert }

      it { is_expected.to eq true }
    end

    context 'expert is unrelated' do
      it { is_expected.to eq false }
    end
  end
end
