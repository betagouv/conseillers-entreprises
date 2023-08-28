# frozen_string_literal: true

module AntenneCoverage
  class DeduplicatedJob
    def initialize(antenne)
      @antenne = antenne
    end

    def call
      # Kill similar jobs that are not run yet (or being run).
      queue = 'antenne_coverage'
      ApplicationJob.remove_delayed_jobs queue do |job|
        payload = job.payload_object
        [payload.object.class, payload.method_name, payload.object.antenne] == [AntenneCoverage::Update, :call, @antenne]
      end

      AntenneCoverage::Update.new(@antenne).delay(queue: 'antenne_coverage').call
    end
  end
end
