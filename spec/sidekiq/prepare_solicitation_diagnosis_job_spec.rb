require 'rails_helper'
RSpec.describe PrepareSolicitationDiagnosisJob, type: :job do
  describe  do
    let(:solicitation) { create(:solicitation) }
    it { expect { PrepareSolicitationDiagnosisJob.perform_async(solicitation.id) }.to enqueue_sidekiq_job.with(solicitation.id) }
  end
end
