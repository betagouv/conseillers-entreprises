# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SidekiqJob do
  describe '.matching_active_job?' do
    let(:job_class) { ActivityReports::AntenneStats }
    let(:item_gid) { 'gid://app/Antenne/2841' }

    def job_double(args)
      instance_double(Sidekiq::JobRecord, args: args)
    end

    context 'when the job is an ActiveJob payload matching the class and item' do
      it 'returns true' do
        args = [
          { 'job_class' => job_class.to_s,
                            'arguments' => [{ '_aj_globalid' => item_gid }] }
        ]

        expect(described_class.matching_active_job?(job_double(args), job_class, item_gid)).to be(true)
      end
    end

    context 'when the job is a plain Sidekiq::Job whose first argument is an Integer' do
      it 'returns false' do
        expect { described_class.matching_active_job?(job_double([2841]), job_class, item_gid) }
          .not_to raise_error
        expect(described_class.matching_active_job?(job_double([2841]), job_class, item_gid)).to be(false)
      end
    end
  end
end
