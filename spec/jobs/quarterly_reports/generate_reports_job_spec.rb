require 'rails_helper'
RSpec.describe QuarterlyReports::GenerateReportsJob, type: :job do
  describe 'enqueue a job with an antenne' do
    let(:antenne) { create(:antenne) }

    it do
      described_class.perform_later(antenne.id)
      assert_enqueued_with(job: described_class, args: [antenne.id])
    end
  end
end
