require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :match
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:match)
        is_expected.to validate_presence_of(:description)
      end
    end
  end

  describe 'can_be_viewed_by?' do
    subject { feedback.can_be_viewed_by?(expert) }

    let(:feedback) { create :feedback }
    let(:expert) { create :expert }

    context 'expert is the expert of the match' do
      before do
        feedback.match.expert = expert
      end

      it { is_expected.to eq true }
    end

    context 'expert is unrelated' do
      before do
        feedback.match.expert = create :expert
      end

      it { is_expected.to eq false }
    end
  end
end
