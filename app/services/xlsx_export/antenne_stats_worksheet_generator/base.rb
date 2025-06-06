module XlsxExport
  module AntenneStatsWorksheetGenerator
    class Base
      def initialize(sheet, antenne, needs, styles)
        @antenne = antenne
        @sheet = sheet
        @needs = needs
        create_styles styles
      end

      def generate
        finalise_style
      end

      private

      # Base variables
      #
      def sheet
        @sheet
      end

      def current_needs
        @current_needs ||= @needs
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
          base_relation.send(:"status_#{status}")&.size
        end
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
        @blue_bg      = s.add_style bg_color: 'CFE2F3', type: :dxf
        @pink_bg      = s.add_style bg_color: 'f4e6ec', type: :dxf

        s
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

        sheet.column_widths 50, 15, 20, 25, 25, 25
      end
    end
  end
end
