require 'rails_helper'

describe RecordExtensions::HumanCount do
  describe 'human_count' do
    subject { user.feedbacks.human_count }

    let(:user) { create :user, feedbacks: create_list(:feedback, count, :for_need) }

    context 'one object' do
      let(:count) { 1 }

      it { is_expected.to eq '1 commentaire' }
    end

    context 'zero objects' do
      let(:count) { 0 }

      it { is_expected.to eq '0 commentaire' }
    end

    context 'several objects' do
      let(:count) { 4 }

      it { is_expected.to eq '4 commentaires' }
    end
  end
end
