# frozen_string_literal: true

class AdminMailersService
  class << self
    def send_statistics_email
      AdminMailer.weekly_statistics(public_stats_counts, reminders_counts).deliver_later
    end

    private

    def public_stats_counts
      params = {
        start_date: 1.week.ago.to_date,
        end_date: Date.today
      }
      stats = Stats::Stats.new(params)
      counts = %i[solicitations solicitations_diagnoses exchange_with_expert taking_care].index_with do |name|
        stats.send(name).count
      end

      { params: params, counts: counts }
    end

    def reminders_counts
      counts = %i[poke recall warn archive].index_with do |name|
        Need.reminders_to(name).human_count
      end

      { counts: counts }
    end
  end
end
