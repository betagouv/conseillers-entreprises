require 'rails_helper'

RSpec.describe Feedback do
  describe 'associations' do
    it do
      is_expected.to belong_to :feedbackable
    end
  end

  describe 'persons_to_notify' do
    let(:advisor) { create :user }
    let(:user3) { create :user }
    let(:expert_taking_care) { create :expert }
    let(:expert_no_help) { create :expert }
    let(:expert_done) { create :expert }
    let(:expert_not_reachable) { create :expert, users: [user3] }
    let!(:matches) do
      [
        create(:match, expert: expert_taking_care, status: 'taking_care'),
        create(:match, expert: expert_no_help, status: 'done_no_help'),
        create(:match, expert: expert_not_reachable, status: 'done_not_reachable'),
        create(:match, expert: expert_done, status: 'done')
      ]
    end
    let(:need) { create :need, advisor: advisor, matches: matches }
    let(:feedback) { create :feedback, :for_need, feedbackable: need, user: author }

    subject { feedback.persons_to_notify }

    context 'when the author is the one of the contacted experts' do
      let(:user2) { create :user }
      let!(:feedback2) { create :feedback, :for_need, feedbackable: need, user: user2 }
      let!(:feedback3) { create :feedback, :for_need, feedbackable: need, user: user3 }
      let(:author) { user3 }

      it { is_expected.to match_array [expert_taking_care, user2, advisor] }
    end

    context 'when some experts arent positioned yet' do
      let(:expert_refuse) { create :expert }
      let!(:refused_match) { create :match, expert: expert_refuse, need: need, status: 'not_for_me' }
      let(:expert_quo) { create :expert }
      let!(:quo_match) { create :match, expert: expert_quo, need: need, status: 'quo' }

      before do
        need.matches << refused_match
        need.matches << quo_match
      end

      context 'when author is a normal user' do
        let(:author) { advisor }

        it 'don’t notify experts not positioned' do
          is_expected.to match_array [expert_taking_care, expert_not_reachable]
        end
      end

      context 'when author is an admin' do
        let(:author) { create :user, :admin }

        it 'notify all experts but not the advisor' do
          is_expected.to match_array [expert_taking_care, expert_not_reachable, expert_quo]
        end
      end
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
      let(:feedback) { travel_to(date3) { create :feedback, :for_solicitation, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { solicitation.feedbacks = [feedback] }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a feedback is removed from a solicitation' do
      let(:feedback) { travel_to(date1) { create :feedback, :for_solicitation, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { feedback.destroy }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a feedback is updated' do
      let(:feedback) { travel_to(date1) { create :feedback, :for_solicitation, feedbackable: solicitation } }

      before do
        feedback
        travel_to(date3) { feedback.update(description: 'New description') }
      end

      it { is_expected.to eq date3 }
    end
  end
end
