module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByPosition < Base
      def initialize(sheet, antenne, needs, start_date, end_date, type, styles)
        @antenne = antenne
        @sheet = sheet
        @start_date = start_date
        @end_date = end_date
        @base_needs = needs
        @type = type
        create_styles styles
      end

      def generate
        generate_base_stats
        generate_matches_stats
        generate_needs_stats
        generate_institution_themes_stats
        generate_occasional_themes_stats
        add_help_row
        finalise_style
      end

      private

      def generate_base_stats
        sheet.add_row [I18n.t('antenne_stats_exporter.subtitle')], style: @subtitle
        sheet.add_row

        sheet.add_row [I18n.t('antenne_stats_exporter.needs'), current_needs.size], style: [@bold, nil]
        sheet.add_row [I18n.t('antenne_stats_exporter.facilities'), facilities.size], style: [@bold, nil]
        sheet.add_row
      end

      def generate_matches_stats
        sheet.add_row [
          I18n.t('antenne_stats_exporter.experts_positionning', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage'),
          previous_header
        ], style: count_rate_header_style

        # Besoins transmis
        sheet.add_row [
          I18n.t('antenne_stats_exporter.transmitted_needs'),
          matches.size
        ], style: count_rate_row_style

        add_status_rows(ordered_scopes, matches, previous_matches)
        add_status_rows([:taken_care_in_three_days, :taken_care_in_five_days], matches.with_exchange, previous_matches)

        sheet.add_row
      end

      def generate_needs_stats
        sheet.add_row [
          I18n.t('antenne_stats_exporter.ecosystem_positionning', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        # Besoins transmis
        sheet.add_row [
          I18n.t('antenne_stats_exporter.transmitted_needs'),
          current_needs.size
        ], style: count_rate_row_style

        add_status_rows(ordered_scopes, current_needs)

        # Subquery pour se débarasser du `join` sur les matches de l'antenne qui fausse les résultats
        unjoined_needs = Need.where(id: current_needs.with_exchange.ids)
        add_status_rows([:taken_care_in_three_days, :taken_care_in_five_days], unjoined_needs)

        sheet.add_row
      end

      def generate_institution_themes_stats
        # On ne prend que les thèmes principaux
        themes = @antenne.institution.themes.for_interview

        sheet.add_row [
          I18n.t('antenne_stats_exporter.institution_themes'),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        generate_themes_rows(themes)
      end

      def generate_occasional_themes_stats
        themes = Theme.for_interview
        # On ne prend que les thèmes que l'antenne n'a pas et sur lesquels elle a été notifiée quand même
        themes = themes.reject do |theme|
          @antenne.institution.themes.include?(theme) ||
          calculate_needs_by_theme_size(theme).zero?
        end

        return if calculate_needs_by_themes_size(themes).zero?

        sheet.add_row [I18n.t('antenne_stats_exporter.occasional_themes'), '', ''], style: count_rate_header_style

        generate_themes_rows(themes)
      end

      # Helpers
      #
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
            calculate_rate(needs_count, current_needs)
          ], style: count_rate_row_style
        end
        sheet.add_row
      end

      def add_status_rows(scopes, recipient, previous_recipient = nil)
        scopes.each do |scope|
          by_status_size = recipient.send(scope)&.size
          row = [
            I18n.t("antenne_stats_exporter.funnel.#{scope}"),
            by_status_size,
            calculate_rate(by_status_size, recipient),
          ]
          row += [calculate_rate(previous_recipient.send(scope)&.size, previous_recipient)] if previous_recipient.present?

          sheet.add_row row, style: count_rate_row_style
        end
      end

      def add_help_row
        sheet.add_row [I18n.t('antenne_stats_exporter.count_difference')], style: [@italic]
        sheet.add_row [I18n.t('antenne_stats_exporter.work_in_progress'),], style: [@italic]
      end

      def finalise_style
        [
          'A1:D1',
          'A2:D2',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 70, 15, 15, 20
      end

      # Base variables
      #
      def sheet
        @sheet
      end

      def institution_name
        @institution_name ||= @antenne.institution.name
      end

      def current_needs
        @current_needs ||= @base_needs.created_between(@start_date, @end_date)
      end

      def matches
        @matches ||= @antenne.perimeter_received_matches_from_needs(current_needs)
      end

      def previous_needs
        if @type == :annual
          previous_range = 1.year
        else
          previous_range = 3.months
        end
        @previous_needs ||= @base_needs.created_between(@start_date - previous_range, @end_date - previous_range)
      end

      def previous_matches
        @previous_matches ||= @antenne.perimeter_received_matches_from_needs(previous_needs)
      end

      def previous_header
        if @type == :annual
          I18n.t('antenne_stats_exporter.previous_year_percentage')
        else
          I18n.t('antenne_stats_exporter.previous_quarter_percentage')
        end
      end

      def facilities
        @facilities ||= Facility.joins(diagnoses: :needs).where(diagnoses: { needs: current_needs }).distinct
      end

      def ordered_scopes
        @ordered_scopes ||= [:not_status_quo, :status_not_for_me, :taken_care_of, :status_done, :status_done_no_help, :status_done_not_reachable, :status_taking_care, :status_quo]
      end

      def ordered_statuses
        @ordered_statuses ||= [:done, :done_not_reachable, :done_no_help, :taking_care, :not_for_me, :quo]
      end

      def ordered_positionning_statuses
        @ordered_positionning_statuses ||= [:positionning, :positionning_accepted, :done, :not_for_me, :quo, nil]
      end

      def calculate_needs_by_theme_size(theme)
        current_needs.joins(subject: :theme).where(subject: { theme: theme }).size
      end

      def calculate_needs_by_themes_size(themes)
        current_needs.joins(subject: :theme).where(subject: { theme: themes }).size
      end

      def calculate_needs_by_subject_size(subject)
        current_needs.where(subject: subject).size
      end

      def count_rate_header_style
        [@left_header, @right_header, @right_header, @right_header, @right_header]
      end

      def count_rate_row_style
        [@label, nil, @rate, @rate]
      end
    end
  end
end
