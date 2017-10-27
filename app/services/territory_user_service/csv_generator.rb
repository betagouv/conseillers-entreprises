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
          I18n.t('activerecord.attributes.visit.happened_on'),
          I18n.t('activerecord.attributes.visit.advisor'),
          I18n.t('activerecord.attributes.user.institution'),
          I18n.t('activerecord.models.question.one'),
          I18n.t('activerecord.attributes.diagnosed_need.content'),
          I18n.t('activerecord.models.expert.one'),
          I18n.t('activerecord.attributes.expert.institution'),
          I18n.t('activerecord.attributes.selected_assistance_expert.status'),
          I18n.t('activerecord.attributes.selected_assistance_expert.taken_care_of_at'),
          I18n.t('activerecord.attributes.selected_assistance_expert.closed_at')
        ]
      end

      def csv_line_from_data(csv_line, diagnosis, diagnosed_need, selected_assistance_expert)
        csv_line << [
          diagnosis.visit.company_name,
          diagnosis.visit.happened_on,
          diagnosis.visit.advisor.full_name,
          diagnosis.visit.advisor.institution,
          diagnosed_need.question_label,
          diagnosed_need.content,
          selected_assistance_expert.expert_full_name,
          selected_assistance_expert.expert_institution_name,
          I18n.t("activerecord.attributes.selected_assistance_expert.statuses.#{selected_assistance_expert.status}"),
          selected_assistance_expert.taken_care_of_at&.to_date,
          selected_assistance_expert.closed_at&.to_date
        ]
        csv_line
      end
    end
  end
end
