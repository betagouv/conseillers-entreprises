# frozen_string_literal: true

class AdminMailersService
  attr_accessor :information_hash, :not_admin_visits, :not_admin_diagnoses, :completed_diagnoses

  class << self
    def send_statistics_email
      @information_hash = {}

      associations = [visit: [:advisor, facility: [:company]]]
      @not_admin_diagnoses = Diagnosis.includes(associations).only_active.of_user(User.not_admin).reverse_chronological
      @completed_diagnoses = @not_admin_diagnoses.completed.updated_last_week

      sign_up_statistics
      created_diagnoses_statistics
      updated_diagnoses_statistics
      completed_diagnoses_statistics
      abandoned_needs_statistics
      matches_count_statistics

      AdminMailer.delay.weekly_statistics(@information_hash)
    end

    private

    def sign_up_statistics
      recently_signed_up_users = User.created_last_week
      @information_hash[:signed_up_users] = {}
      @information_hash[:signed_up_users][:count] = recently_signed_up_users.count
      @information_hash[:signed_up_users][:items] = recently_signed_up_users
    end

    def created_diagnoses_statistics
      created_diagnoses = @not_admin_diagnoses.in_progress.created_last_week
      @information_hash[:created_diagnoses] = {}
      @information_hash[:created_diagnoses][:count] = created_diagnoses.count
      @information_hash[:created_diagnoses][:items] = created_diagnoses
    end

    def updated_diagnoses_statistics
      updated_diagnoses = @not_admin_diagnoses.in_progress.updated_last_week
      updated_diagnoses = updated_diagnoses.where('diagnoses.created_at < ?', 1.week.ago)
      @information_hash[:updated_diagnoses] = {}
      @information_hash[:updated_diagnoses][:count] = updated_diagnoses.count
      @information_hash[:updated_diagnoses][:items] = updated_diagnoses
    end

    def completed_diagnoses_statistics
      @information_hash[:completed_diagnoses] = {}
      @information_hash[:completed_diagnoses][:count] = @completed_diagnoses.count
      @information_hash[:completed_diagnoses][:items] = @completed_diagnoses
    end

    def abandoned_needs_statistics
      abandoned_needs = DiagnosedNeed.abandoned
      @information_hash[:abandoned_needs_count] = abandoned_needs.count
    end

    def matches_count_statistics
      matches_count = Match.of_diagnoses(@completed_diagnoses).count
      @information_hash[:matches_count] = matches_count
    end
  end
end
