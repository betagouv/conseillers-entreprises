require 'rails_helper'
RSpec.describe PrepareSolicitationDiagnosisJob, type: :job do
  describe 'enqueue a job with a solicitation' do
    let(:solicitation) { create(:solicitation) }

    it do
      described_class.perform_later(solicitation.id)
      assert_enqueued_with(job: described_class, args: [solicitation.id])
    end
  end
end
