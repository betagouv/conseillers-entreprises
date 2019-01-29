# frozen_string_literal: true

module RelayService
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
          diagnosed_need.matches.each do |match|
            csv_line = csv_line_from_data(csv_line, diagnosis, diagnosed_need, match)
          end
        end
        csv_line
      end

      # rubocop:disable Metrics/MethodLength
      def csv_first_line
        [
          I18n.t('activerecord.models.company.one'),
          I18n.t('attributes.happened_on'),
          I18n.t('attributes.advisor'),
          I18n.t('attributes.institution'),
          I18n.t('activerecord.models.question.one'),
          I18n.t('attributes.content'),
          I18n.t('activerecord.models.expert.one'),
          I18n.t('attributes.institution'),
          I18n.t('activerecord.attributes.match.status'),
          I18n.t('activerecord.attributes.match.taken_care_of_at'),
          I18n.t('activerecord.attributes.match.closed_at')
        ]
      end

      # rubocop:disable Metrics/AbcSize
      def csv_line_from_data(csv_line, diagnosis, diagnosed_need, match)
        csv_line << [
          diagnosis.company.name,
          diagnosis.happened_on,
          diagnosis.advisor.full_name,
          diagnosis.advisor.institution,
          diagnosed_need.question_label,
          diagnosed_need.content,
          match.expert_full_name,
          match.expert_institution_name,
          I18n.t("activerecord.attributes.match.statuses.#{match.status}"),
          match.taken_care_of_at&.to_date,
          match.closed_at&.to_date
        ]
        csv_line
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
