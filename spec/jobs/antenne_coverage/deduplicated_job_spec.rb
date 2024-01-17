require 'rails_helper'

RSpec.describe AntenneCoverage::DeduplicatedJob do
  describe '#perform' do
    let(:institution) { create(:institution) }
    let(:beaufay) { create(:commune, insee_code: '72026') }
    let(:communes) { [beaufay] }
    let!(:antenne) { create(:antenne, :local, institution: institution, communes: communes) }

    before { Sidekiq::ScheduledSet.new.clear }

    it do
      scheduled = Sidekiq::ScheduledSet.new

      expect(scheduled.size).to eq 0
      antenne.update(communes: [])
      service_scheduled = scheduled.select{ |job| job['class'] == "AntenneCoverage::DeduplicatedJob" }
      expect(service_scheduled.size).to eq 1
      expect(service_scheduled.first.args).to eq [antenne.id]
      first_job = service_scheduled.first

      # Pas de nouveau job rajouté si on modifie la même antenne
      antenne.update(communes: [beaufay])
      expect(service_scheduled.size).to eq 1
      expect(service_scheduled.first.args).to eq [antenne.id]
      second_job = service_scheduled.first
      expect(first_job['args']).to eq second_job['args']
      expect(first_job['class']).to eq second_job['class']
      expect(first_job['queue']).to eq second_job['queue']
    end
  end
end
