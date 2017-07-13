# frozen_string_literal: true

class AdminMailersService
  attr_accessor :information_hash, :not_admin_visits

  class << self
    def send_statistics_email
      @information_hash = {}

      regular_users_ids = User.not_admin.pluck(:id)
      @not_admin_visits = Visit.where(advisor_id: regular_users_ids).includes(:advisor)

      sign_up_statistics
      visits_statistics
      diagnoses_statistics
      mailto_statistics

      AdminMailer.weekly_statistics(@information_hash).deliver_now
    end

    private

    def sign_up_statistics
      recently_signed_up_users = User.created_last_week
      @information_hash[:signed_up_users] = {}
      @information_hash[:signed_up_users][:count] = recently_signed_up_users.count
      @information_hash[:signed_up_users][:items] = recently_signed_up_users
    end

    def visits_statistics
      recent_visits = @not_admin_visits.created_last_week.group(:advisor).count
      @information_hash[:visits] = recent_visits.collect do |user, count|
        { user: user, visits_count: count }
      end
    end

    def diagnoses_statistics
      recent_diagnoses = Diagnosis.created_last_week.where(visit: @not_admin_visits).group(:visit).count
      @information_hash[:diagnoses] = recent_diagnoses.collect do |visit, count|
        { visit: visit, diagnoses_count: count }
      end
    end

    def mailto_statistics
      recent_mailto_logs = MailtoLog.created_last_week.where(visit: @not_admin_visits).group(:visit).count
      @information_hash[:mailto_logs] = recent_mailto_logs.collect do |visit, count|
        { visit: visit, logs_count: count }
      end
    end
  end
end
