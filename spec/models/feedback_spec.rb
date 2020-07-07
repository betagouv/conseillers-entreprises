require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :feedbackable
    end
  end

  describe 'persons_to_notify' do
    let(:advisor) { create :user }
    let(:user3) { create :user }
    let(:expert1) { create :expert }
    let(:expert2) { create :expert }
    let(:expert3) { create :expert, users: [user3] }
    let(:matches) { [create(:match, expert: expert1), create(:match, expert: expert2), create(:match, expert: expert3)] }
    let(:need) { create :need, advisor: advisor, matches: matches }
    let(:feedback) { create :feedback, feedbackable: need, user: author }

    subject { feedback.persons_to_notify }

    context 'when the author is the one of the contacted experts' do
      let(:user2) { create :user }
      let!(:feedback2) { create :feedback, feedbackable: need, user: user2 }
      let!(:feedback3) { create :feedback, feedbackable: need, user: user3 }
      let(:author) { user3 }

      it{ is_expected.to match_array [expert1, expert2, user2, advisor] }
    end

    context 'when the author is the diagnosis advisor' do
      let(:author) { advisor }

      it{ is_expected.to match_array [expert1, expert2, expert3] }
    end
  end

  describe 'touch solicitations' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:solicitation) { travel_to(date1) { create :solicitation } }

    before { solicitation }

    subject { solicitation.reload.updated_at }

    context 'when a feedback is added to a solicitation' do
      let(:feedback) { travel_to(date3) { create :feedback, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { solicitation.feedbacks = [feedback] }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a feedback is removed from a solicitation' do
      let(:feedback) { travel_to(date1) { create :feedback, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { feedback.destroy }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a feedback is updated' do
      let(:feedback) { travel_to(date1) { create :feedback, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { feedback.update(description: 'New description') }
      end

      it { is_expected.to eq date3 }
    end
  end
end
