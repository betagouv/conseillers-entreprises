class AntenneCoverage::DeduplicatedJob
  include Sidekiq::Job
  QUEUE_NAME = 'antenne_coverage'

  # Updated when changed : add/remove communes - add/remove experts - add/remove expert communes - add/remove expert subject
  def perform(antenne_id)
    current_antenne = Antenne.find(antenne_id)
    # pour que les tests passent
    return unless current_antenne.persisted?
    if current_antenne.regional?
      update_antenne_coverage(current_antenne)
      current_antenne.territorial_antennes.each { |ta| update_antenne_coverage(ta) }
    elsif current_antenne.regional_antenne.present?
      current_antenne.regional_antenne.territorial_antennes.each { |ta| update_antenne_coverage(ta) }
    else
      update_antenne_coverage(current_antenne)
    end
  end

  private

  def update_antenne_coverage(antenne)
    delete_jobs_already_in_queue(antenne)
    AntenneCoverage::UpdateJob.perform_in(1.minute, antenne.id)
  end

  def delete_jobs_already_in_queue(antenne)
    scheduled = Sidekiq::ScheduledSet.new

    scheduled.each do |job|
      return if job['queue'] != QUEUE_NAME
      if job['class'] == AntenneCoverage::UpdateJob.to_s && job['args'].first == antenne.id
        job.delete
      end
    end
  end
end
