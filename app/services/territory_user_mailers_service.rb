# frozen_string_literal: true

class TerritoryUserMailersService
  attr_accessor :territory, :information_hash, :not_admin_visits, :not_admin_territory_diagnoses, :completed_diagnoses

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
      TerritoryUserMailer.delay.weekly_statistics(territory_user, @information_hash, stats_csv)
    end

    def prepare_diagnoses_for_territory(territory)
      associations = [visit: [:advisor, facility: [:company]],
                      diagnosed_needs: %i[question selected_assistance_experts]]
      @not_admin_territory_diagnoses = Diagnosis.includes(associations)
                                                .of_user(User.not_admin)
                                                .in_territory(territory)
                                                .reverse_chronological
      @completed_diagnoses = @not_admin_territory_diagnoses.completed.updated_last_week
    end

    def created_diagnoses_statistics
      created_diagnoses = @not_admin_territory_diagnoses.in_progress.created_last_week
      @information_hash[:created_diagnoses] = {}
      @information_hash[:created_diagnoses][:count] = created_diagnoses.count
      @information_hash[:created_diagnoses][:items] = created_diagnoses
    end

    def updated_diagnoses_statistics
      updated_diagnoses = @not_admin_territory_diagnoses.in_progress.updated_last_week
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

    def stats_csv
      csv = CSV.generate(csv_head, col_sep: ';') do |csv_line|
        csv_line << csv_first_line
        @not_admin_territory_diagnoses.each { |diagnosis| csv_line = csv_line_from_diagnosis(csv_line, diagnosis) }
      end
      csv.delete '=' # Prevent from CSV Injection : http://georgemauer.net/2017/10/07/csv-injection.html
    end

    def csv_head
      %w[EF BB BF].map { |a| a.hex.chr }.join # Adding BOM to CSV, allowing Excel to open it
    end

    def csv_line_from_diagnosis(csv_line, diagnosis)
      diagnosis.diagnosed_needs.each do |diagnosed_need|
        diagnosed_need.selected_assistance_experts.each do |selected_assistance_expert|
          csv_line = csv_line_from_data(csv_line, diagnosis, diagnosed_need, selected_assistance_expert)
        end
      end
      csv_line
    end

    def csv_first_line
      [
        I18n.t('activerecord.models.company.one'),
        I18n.t('activerecord.attributes.visit.happened_at'),
        I18n.t('activerecord.attributes.visit.advisor'),
        I18n.t('activerecord.models.question.one'),
        I18n.t('activerecord.models.expert.one'),
        I18n.t('activerecord.attributes.selected_assistance_expert.status')
      ]
    end

    def csv_line_from_data(csv_line, diagnosis, diagnosed_need, selected_assistance_expert)
      csv_line << [
        diagnosis.visit.company_name,
        diagnosis.visit.happened_at,
        diagnosis.visit.advisor.full_name,
        diagnosed_need.question,
        selected_assistance_expert.expert_full_name,
        I18n.t("activerecord.attributes.selected_assistance_expert.statuses.#{selected_assistance_expert.status}")
      ]
      csv_line
    end
  end
end
