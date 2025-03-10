module XlsxExport
  module CooperationWorksheetGenerator
    class Base
      def initialize(sheet, cooperation, start_date, end_date, styles)
        @cooperation = cooperation
        @start_date = start_date.beginning_of_day
        @end_date = end_date.end_of_day
        @sheet = sheet
        create_styles styles
      end

      def generate; end

      private

      def generate_themes_rows(themes)
        needs_by_themes = {}
        themes.each do |theme|
          needs_by_themes[theme.label] = theme.present? ? calculate_needs_by_theme_size(theme) : nil
        end

        # Tri selon le nombre de besoins en ordre décroissant
        needs_by_themes.sort_by { |_, needs_count| -needs_count }.each do |theme_label, needs_count|
          sheet.add_row [
            theme_label,
            needs_count,
            calculate_rate(needs_count, base_needs)
          ], style: count_rate_row_style
        end
        sheet.add_row
      end

      def add_header_row(scope)
        sheet.add_row [
          I18n.t("cooperation_stats_exporter.#{scope}"),
          I18n.t('cooperation_stats_exporter.count'),
          I18n.t('cooperation_stats_exporter.percentage')
        ], style: count_rate_header_style
      end

      def add_count_percentage_row(label, count, base_items)
        sheet.add_row [
          label,
          count,
          calculate_rate(count, base_items)
        ], style: count_rate_row_style
      end

      def add_status_row(scope, count, base_items)
        add_count_percentage_row(I18n.t("cooperation_stats_exporter.funnel.#{scope}"), count, base_items)
      end

      def finalise_style
        [
          'A1:E1',
          'A2:E2',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 15, 15, 15
      end

      # Base variables
      #
      def sheet
        @sheet
      end

      def base_solicitations
        @base_solicitations ||= Solicitation.step_complete
          .where(completed_at: @start_date..@end_date)
          .where(cooperation_id: @cooperation.id)
      end

      def base_needs
        @base_needs ||= Need.diagnosis_completed
          .joins(:diagnosis).merge(Diagnosis.from_solicitation)
          .where(created_at: @start_date..@end_date)
          .joins(solicitation: :cooperation)
          .where(solicitations: { cooperations: { id: @cooperation.id } })
      end

      # Calculation
      #
      def calculate_rate(count, base_relation)
        return unless count.present? && base_relation.present?
        count / base_relation.size.to_f
      end

      def calculate_needs_by_theme_size(theme)
        base_needs.joins(subject: :theme).where(subject: { theme: theme }).size
      end

      # Style
      #
      def create_styles(s)
        @subtitle     = s.add_style bg_color: 'eadecd', sz: 14, b: true, alignment: { horizontal: :center, vertical: :center }, border: { color: 'AAAAAA', style: :thin }
        @bold         = s.add_style b: true
        @italic       = s.add_style i: true
        @left_header  = s.add_style bg_color: 'eadecd', b: true, alignment: { horizontal: :left }, border: { color: 'AAAAAA', style: :thin }
        @right_header = s.add_style bg_color: 'eadecd', b: true, alignment: { horizontal: :right }, border: { color: 'AAAAAA', style: :thin }
        @label        = s.add_style alignment: { indent: 1 }
        @rate         = s.add_style format_code: '#0.0%'
        s
      end

      def count_rate_header_style
        [@left_header, @right_header, @right_header, @right_header, @right_header]
      end

      def count_rate_row_style
        [@label, nil, @rate]
      end
    end
  end
end
