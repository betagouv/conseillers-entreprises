module XlsxExport
  module AntenneStatsWorksheetGenerator
    class Base
      def initialize(sheet, antenne, needs, styles)
        @antenne = antenne
        @needs = needs
        @sheet = sheet
        create_styles styles
      end

      def generate
        generate_base_stats
        generate_matches_stats
        generate_needs_stats
        generate_themes_stats
        finalise_style
      end

      private

      def generate_base_stats
        sheet.add_row [I18n.t('antenne_stats_exporter.subtitle')], style: @subtitle
        sheet.add_row

        sheet.add_row [I18n.t('antenne_stats_exporter.needs'), @needs.size], style: [@bold, nil]
        sheet.add_row [I18n.t('antenne_stats_exporter.facilities'), facilities.size], style: [@bold, nil]
        sheet.add_row
      end

      def generate_themes_stats
        # On ne prend que les thèmes principaux
        themes = Theme.for_interview.limit(10)

        sheet.add_row [
          Theme.model_name.human,
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        needs_by_themes = {}
        themes.each do |theme|
          needs_by_themes[theme.label] = theme.present? ? calculate_needs_by_theme_size(theme) : nil
        end

        # Tri selon le nombre de besoins en ordre décroissant
        needs_by_themes.sort_by { |_, needs_count| -needs_count }.each do |theme_label, needs_count|
          sheet.add_row [
            theme_label,
            needs_count,
            calculate_rate(needs_count, @needs)
          ], style: count_rate_row_style
        end
        sheet.add_row
      end

      def generate_matches_stats
        sheet.add_row [
          I18n.t('antenne_stats_exporter.experts_positionning', institution: institution_name),
          I18n.t('antenne_stats_exporter.count'),
          I18n.t('antenne_stats_exporter.percentage')
        ], style: count_rate_header_style

        # Besoins transmis
        sheet.add_row [
          I18n.t('antenne_stats_exporter.transmitted_needs'),
          matches.size
        ], style: count_rate_row_style

        add_status_rows(ordered_scopes, matches)

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
          @needs.size
        ], style: count_rate_row_style

        add_status_rows(ordered_scopes, @needs)

        sheet.add_row
      end

      def add_status_rows(scopes, recipient)
        scopes.each do |scope|
          by_status_size = recipient.send(scope)&.size
          sheet.add_row [
            I18n.t("antenne_stats_exporter.funnel.#{scope}"),
            by_status_size,
            calculate_rate(by_status_size, recipient)
          ], style: count_rate_row_style
        end
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

      def institution_name
        @institution_name ||= @antenne.institution.name
      end

      def matches
        @matches ||= @antenne.perimeter_received_matches_from_needs(@needs)
      end

      def facilities
        @facilities ||= Facility.joins(diagnoses: :needs).where(diagnoses: { needs: @needs }).distinct
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

      # Calculation
      #
      def calculate_rate(status_size, base_relation)
        return unless status_size.present? && base_relation.present?
        status_size / base_relation.size.to_f
      end

      def calculate_positionning_status_size(status, base_relation)
        return unless status
        case status
        # Pris en charge, refusé, clôturé avec aide, clôturé sans aide, injoignable
        when :positionning
          base_relation.size - base_relation.status_quo.size
        # Pris en charge, clôturé avec aide, clôturé sans aide, injoignable
        when :positionning_accepted
          base_relation.size - (base_relation.status_quo.size + base_relation.status_not_for_me.size)
        else
          base_relation.send("status_#{status}")&.size
        end
      end

      def calculate_needs_by_theme_size(theme)
        @needs.joins(subject: :theme).where(subject: { theme: theme }).size
      end

      def calculate_needs_by_subject_size(subject)
        @needs.where(subject: subject).size
      end

      # Style
      #
      def create_styles(s)
        @subtitle     = s.add_style bg_color: 'eadecd', sz: 14, b: true, alignment: { horizontal: :center, vertical: :center }, border: { color: 'AAAAAA', style: :thin }
        @bold         = s.add_style b: true
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

      # Pages résumé
      #
      def add_agglomerate_headers(tab_scope)
        sheet.add_row [
          I18n.t(tab_scope, scope: ['antenne_stats_exporter']),
          I18n.t('antenne_stats_exporter.needs_count'),
          I18n.t('antenne_stats_exporter.needs_percentage'),
          I18n.t('antenne_stats_exporter.positionning_rate'),
          I18n.t('antenne_stats_exporter.positionning_accepted_rate'),
          I18n.t('antenne_stats_exporter.done_rate')
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]
      end

      def add_agglomerate_rows(needs, row_title, recipient, ratio = nil)
        matches = recipient.perimeter_received_matches_from_needs(needs)
        positionning_size = calculate_positionning_status_size(:positionning, matches)
        positionning_accepted_size = calculate_positionning_status_size(:positionning_accepted, matches)
        done_size = calculate_positionning_status_size(:done, matches)
        sheet.add_row [
          row_title,
          needs.size,
          ratio,
          calculate_rate(positionning_size, matches),
          calculate_rate(positionning_accepted_size, matches),
          calculate_rate(done_size, matches),
        ], style: [nil, nil, @rate, @rate, @rate, @rate]
      end

      def finalise_agglomerate_style
        [
          'A1:F1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 25, 25, 25, 25
      end
    end
  end
end
