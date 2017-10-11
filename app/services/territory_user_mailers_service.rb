# frozen_string_literal: true

class TerritoryUserMailersService
  attr_accessor :territory, :information_hash, :not_admin_visits, :not_admin_diagnoses, :completed_diagnoses

  class << self
    def send_statistics_email
      territory_users = TerritoryUser.all.includes(territory: :territory_cities)
      territory_users.each { |territory_user| send_statistics_email_to_territory_user(territory_user) }
    end

    private

    def send_statistics_email_to_territory_user(territory_user)
      @information_hash = {}
      prepare_diagnoses_for_territory(territory_user.territory)
      created_diagnoses_statistics
      updated_diagnoses_statistics
      completed_diagnoses_statistics
      contacted_experts_count_statistics
      TerritoryUserMailer.delay.weekly_statistics(territory_user.user, territory_user.territory.name, @information_hash)
    end

    def prepare_diagnoses_for_territory(territory)
      associations = [visit: [:advisor, facility: [:company]]]
      @not_admin_diagnoses = Diagnosis.includes(associations)
                                      .of_user(User.not_admin)
                                      .in_territory(territory)
                                      .reverse_chronological
      @completed_diagnoses = @not_admin_diagnoses.completed.updated_last_week
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

    def contacted_experts_count_statistics
      contacted_experts_count = SelectedAssistanceExpert.of_diagnoses(@completed_diagnoses).count
      @information_hash[:contacted_experts_count] = contacted_experts_count
    end
  end
end
