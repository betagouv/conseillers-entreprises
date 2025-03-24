require 'rails_helper'
RSpec.describe ActivityReports::Cooperation::GenerateJob do
  describe 'enqueue a job with an antenne' do
    let(:cooperation) { create(:cooperation) }

    it do
      described_class.perform_later(cooperation.id)
      assert_enqueued_with(job: described_class, args: [cooperation.id])
    end
  end
end
