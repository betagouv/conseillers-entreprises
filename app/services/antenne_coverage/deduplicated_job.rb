# frozen_string_literal: true

module AntenneCoverage
  class DeduplicatedJob
    QUEUE_NAME = 'antenne_coverage'

    def initialize(antenne)
      @current_antenne = antenne
    end

    # Updated when changed : add/remove communes - add/remove experts - add/remove expert communes - add/remove expert subject
    def call
      # pour que les tests passent
      return unless @current_antenne.persisted?
      return if job_already_in_queue?
      if @current_antenne.regional?
        update_antenne_coverage(@current_antenne)
        @current_antenne.territorial_antennes.each { |ta| update_antenne_coverage(ta) }
      elsif @current_antenne.regional_antenne.present?
        @current_antenne.regional_antenne.territorial_antennes.each { |ta| update_antenne_coverage(ta) }
      else
        update_antenne_coverage(@current_antenne)
      end
    end

    private

    def update_antenne_coverage(antenne)
      # Kill similar jobs that are not run yet (or being run).
      ApplicationJob.remove_delayed_jobs QUEUE_NAME do |job|
        payload = job.payload_object
        [payload.object.class, payload.method_name, payload.object.antenne] == [AntenneCoverage::Update, :call, antenne]
      end

      AntenneCoverage::Update.new(antenne).delay(queue: QUEUE_NAME, run_at: 1.minute.from_now).call
    end

    def job_already_in_queue?
      jobs = Delayed::Backend::ActiveRecord::Job.where(queue: QUEUE_NAME)
      # /!\ bien comparer les ids, les objets sont pas forcément les mêmes
      jobs.any?{ |job| job.payload_object.antenne.id == @current_antenne.id }
    end
  end
end
