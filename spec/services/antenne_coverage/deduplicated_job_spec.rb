# frozen_string_literal: true

require 'rails_helper'
describe AntenneCoverage::DeduplicatedJob do

  describe '#call' do
    let(:institution) { create(:institution) }
    let(:beaufay) { create(:commune, insee_code: '72026') }
    let(:communes) { [beaufay] }
    let!(:antenne) { create(:antenne, :local, institution: institution, communes: communes) }

    it do
      expect(Delayed::Job.count).to eq 0
      antenne.update(communes: [])
      expect(Delayed::Job.count).to eq 1
      expect(Delayed::Job.last.payload_object.object.antenne).to eq antenne
      first_job = Delayed::Job.first
      antenne.update(communes: [beaufay])
      expect(Delayed::Job.count).to eq 1
      expect(Delayed::Job.last.payload_object.object.antenne).to eq antenne
      second_job = Delayed::Job.first
      expect(first_job).not_to eq second_job
    end
  end
end
