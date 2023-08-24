# frozen_string_literal: true

class DeduplicateCoverageJobsService
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    # Kill similar jobs that are not run yet (or being run).
    queue = 'antenne_coverage'
    ApplicationJob.remove_delayed_jobs queue do |job|
      payload = job.payload_object
      [payload.object.class, payload.method_name] == [UpdateAntenneCoverage, :call] && payload.object.antenne == @antenne
    end

    UpdateAntenneCoverage.new(@antenne).delay(queue: 'antenne_coverage').call
  end
end
