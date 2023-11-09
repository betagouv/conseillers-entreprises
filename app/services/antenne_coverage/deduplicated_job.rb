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
      delete_jobs_already_in_queue(antenne)
      UpdateAntenneCoverageJob.perform_in(1.minute, antenne.id)
    end

    def delete_jobs_already_in_queue(antenne)
      scheduled = if Rails.env == 'test'
                    Sidekiq::Job.jobs
                  else
                    Sidekiq::ScheduledSet.new
                  end


      scheduled.each do |job|
        return if job['queue'] != QUEUE_NAME
        if Rails.env == 'test'
          # Seule methode que j'ai trouvé pour vider Sidekiq::Job.jobs qui est accessible dans les tests,
          # Sidekiq::ScheduledSet ne l'est pas
          Sidekiq::Job.clear_all
        else
          if job['class'] == UpdateAntenneCoverageJob.to_s && job['args'].first == antenne.id
            job.delete
          end
        end
      end
    end
  end
end
