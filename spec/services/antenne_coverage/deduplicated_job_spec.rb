# frozen_string_literal: true

require 'rails_helper'
describe AntenneCoverage::DeduplicatedJob do

  describe '#call' do
    let(:institution) { create(:institution) }
    let(:beaufay) { create(:commune, insee_code: '72026') }
    let(:communes) { [beaufay] }
    let!(:antenne) { create(:antenne, :local, institution: institution, communes: communes) }

    it do
      expect(Sidekiq::Job.jobs.count).to eq 0
      antenne.update(communes: [])
      expect(Sidekiq::Job.jobs.count).to eq 1
      expect(Sidekiq::Job.jobs.last['args']).to eq [antenne.id]
      first_job = Sidekiq::Job.jobs.first

      # Pas de nouveau job rajouté si on modifie la même antenne
      antenne.update(communes: [beaufay])
      expect(Sidekiq::Job.jobs.count).to eq 1
      expect(Sidekiq::Job.jobs.last['args']).to eq [antenne.id]
      second_job = Delayed::Job.first
      expect(first_job).to eq second_job
    end
  end
end
