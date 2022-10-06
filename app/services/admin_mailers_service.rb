# frozen_string_literal: true

class AdminMailersService
  class << self
    def send_statistics_email
      AdminMailer.weekly_statistics(public_stats_counts, reminders_counts).deliver_later
    end

    def send_failed_jobs
      failed_jobs = Delayed::Backend::ActiveRecord::Job.where.not(failed_at: nil).as_json
      if failed_jobs.any?
        AdminMailer.failed_jobs(failed_jobs).deliver_later
      end
    end

    private

    def public_stats_counts
      params = {
        start_date: 1.week.ago.to_date,
        end_date: Date.today
      }
      stats = Stats::Public::All.new(params)
      counts = %i[solicitations solicitations_diagnoses exchange_with_expert taking_care].index_with do |name|
        stats.send(name).count
      end

      { params: params, counts: counts }
    end

    def reminders_counts
      counts = %i[poke recall last_chance].index_with do |name|
        Need.reminders_to(name).human_count
      end

      { counts: counts }
    end
  end
end
