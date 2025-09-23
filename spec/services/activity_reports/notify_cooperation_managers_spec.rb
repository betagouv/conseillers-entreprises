require 'rails_helper'
require 'api_helper'

describe ActivityReports::NotifyCooperationManagers do
  describe 'call' do
    let(:cooperation) { create :cooperation }
    let!(:activity_report) { create :activity_report, :category_cooperation, reportable: cooperation, start_date: 3.months.ago.beginning_of_month }
    let!(:manager) { create :user, :manager, managed_cooperations: [cooperation] }
    let!(:normal_user) { create :user }

    subject { described_class.new.call }

    it 'send a mail to managers' do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        subject
      end
      expect(enqueued_jobs.count).to eq 1
    end
  end
end
