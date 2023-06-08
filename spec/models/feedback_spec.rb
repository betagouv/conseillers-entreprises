require 'rails_helper'

RSpec.describe Feedback do
  describe 'associations' do
    it do
      is_expected.to belong_to :feedbackable
    end
  end

  describe 'persons_to_notify' do
    let(:advisor) { create :user, :admin }
    let(:expert_taking_care) { create :expert_with_users }
    let(:expert_no_help) { create :expert_with_users }
    let(:expert_done) { create :expert_with_users }
    let(:expert_not_reachable) { create :expert_with_users }
    let(:expert_refuse) { create :expert_with_users }
    let(:expert_quo) { create :expert_with_users }
    let!(:matches) do
      [
        create(:match, expert: expert_taking_care, status: 'taking_care'),
        create(:match, expert: expert_no_help, status: 'done_no_help'),
        create(:match, expert: expert_not_reachable, status: 'done_not_reachable'),
        create(:match, expert: expert_done, status: 'done'),
        create(:match, expert: expert_refuse, status: 'not_for_me'),
        create(:match, expert: expert_quo, status: 'quo')
      ]
    end
    let(:need) { create :need, advisor: advisor, matches: matches }
    let(:feedback) { create :feedback, :for_need, feedbackable: need, user: author }
    let!(:feedback_done) { create :feedback, :for_need, feedbackable: need, user: expert_done.users.first }
    let!(:feedback_tacking_care) { create :feedback, :for_need, feedbackable: need, user: expert_taking_care.users.first }

    subject { feedback.persons_to_notify }

    context 'when the author is the one of the contacted experts' do
      let(:user2) { create :user, experts: [expert_taking_care] }
      let(:author_match) { create(:match, expert: create(:expert), status: 'taking_care', need: need) }

      let!(:feedback2) { create :feedback, :for_need, feedbackable: need, user: user2 }
      let!(:feedback3) { create :feedback, :for_need, feedbackable: need, user: author }
      let(:author) { create :user, experts: [author_match.expert] }

      it { is_expected.to contain_exactly(expert_taking_care, advisor, expert_not_reachable) }
    end

    context 'when author is an admin' do
      let!(:author) { create :user, :admin }

      it 'Don’t notify advisor' do
        is_expected.to contain_exactly(expert_taking_care, expert_not_reachable, expert_quo)
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
