require 'rails_helper'
RSpec.describe CompanyEmails::SendStatusNotificationJob do
  describe 'enqueue a job with a match' do
    let(:a_match) { create(:match) }

    xit do
      described_class.perform_async(a_match.id, 'quo')
      expect(Sidekiq::Job.jobs.count).to eq(1)
      expect(Sidekiq::Job.jobs.first['args']).to eq([a_match.id, 'quo'])
    end
  end

  describe '#should_notify_everyone' do
    context 'with match.status done_not_reachable' do
      let(:previous_status) { 'quo' }
      let(:new_status) { 'done_not_reachable' }
      let(:a_match) { create(:match, status: new_status) }

      it 'send an email' do
        assert_enqueued_jobs(1) { described_class.perform_sync(a_match.id, previous_status) }
      end
    end

    context "others status" do
      # Les combinaisons de `should_notify_everyone` qui notifient tout le monde
      %w[taking_care done].each do |new_status|
        %w[quo not_for_me].each do |previous_status|
          it 'notifies everyone' do
            assert_enqueued_jobs(1) do
              described_class.perform_sync(create(:match, status: new_status).id, previous_status)
            end
          end
        end
      end

      # Les autres cas n'envoient pas d'emails
      Match.statuses.keys.delete_if { |x| %w[taking_care done done_not_reachable].include? x }.each do |new_status|
        Match.statuses.keys.delete_if { |x| %w[quo not_for_me].include? x }.each do |previous_status|
          it 'does not notify everyone' do
            assert_no_enqueued_jobs do
              described_class.perform_sync(create(:match, status: new_status).id, previous_status)
            end
          end
        end
      end
    end
  end
end
