# frozen_string_literal: true

class AdminMailersService
  attr_accessor :information_hash, :not_admin_visits, :not_admin_diagnoses, :completed_diagnoses

  class << self
    def send_statistics_email
      @information_hash = {}

      @not_admin_diagnoses = Diagnosis.of_user(User.not_admin)
      @completed_diagnoses = @not_admin_diagnoses.completed.updated_last_week

      sign_up_statistics
      completed_diagnoses_statistics
      contacted_experts_count_statistics

      AdminMailer.delay.weekly_statistics(@information_hash)
    end

    private

    def sign_up_statistics
      recently_signed_up_users = User.created_last_week
      @information_hash[:signed_up_users] = {}
      @information_hash[:signed_up_users][:count] = recently_signed_up_users.count
      @information_hash[:signed_up_users][:items] = recently_signed_up_users
    end

    def completed_diagnoses_statistics
      @information_hash[:completed_diagnoses] = {}
      @information_hash[:completed_diagnoses][:count] = @completed_diagnoses.count
      @information_hash[:completed_diagnoses][:items] = @completed_diagnoses
    end

    def contacted_experts_count_statistics
      contacted_experts_count = SelectedAssistanceExpert.of_diagnoses(@completed_diagnoses).count
      @information_hash[:contacted_experts_count] = contacted_experts_count
    end
  end
end
