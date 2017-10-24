# frozen_string_literal: true

module TerritoryUserService
  class CSVGenerator
    class << self
      def generate_statistics_csv(diagnoses)
        csv = CSV.generate(csv_head, col_sep: ';') do |csv_line|
          csv_line << csv_first_line
          diagnoses.each { |diagnosis| csv_line = csv_line_from_diagnosis(csv_line, diagnosis) }
        end
        csv.delete '=' # Prevent from CSV Injection : http://georgemauer.net/2017/10/07/csv-injection.html
      end

      private

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
end
