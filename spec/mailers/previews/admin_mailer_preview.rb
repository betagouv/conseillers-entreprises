class AdminMailerPreview < ActionMailer::Preview
  def weekly_statistics
    public_stats_counts = {
      params: {
        start_date: 1.week.ago.to_date,
        end_date: Date.today
      },
      counts: {
        solicitations: '80',
        solicitations_diagnoses: '85%',
        exchange_with_expert: '87%',
        taking_care: '100%'
      }
    }
    reminders_counts = {
      counts: {
        poke: 18,
        last_chance: 9,
        archive: 20
      }
    }

    AdminMailer.weekly_statistics(public_stats_counts, reminders_counts)
  end

  def failed_jobs
    jobs_count = Sidekiq::Failures.count
    AdminMailer.failed_jobs(jobs_count)
  end
end
