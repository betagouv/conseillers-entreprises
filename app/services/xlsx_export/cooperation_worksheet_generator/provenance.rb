module XlsxExport
  module CooperationWorksheetGenerator
    class Provenance < Base
      STATUS = %w[done_no_help done_not_reachable quo taking_care not_for_me]

      def generate
        p "PROVENANCE ==========================="

        # Header
        header_row = [
          I18n.t('cooperation_stats_exporter.provenance.provenance_detail'),
          I18n.t('cooperation_stats_exporter.provenance.solicitations_count'),
          I18n.t('cooperation_stats_exporter.provenance.abandonned_count'),
          I18n.t('cooperation_stats_exporter.provenance.abandonned_rate'),
          I18n.t('cooperation_stats_exporter.provenance.matched_count'),
          I18n.t('cooperation_stats_exporter.provenance.matched_rate'),
          I18n.t('cooperation_stats_exporter.provenance.done_count'),
          I18n.t('cooperation_stats_exporter.provenance.done_matches_rate'),
          I18n.t('cooperation_stats_exporter.provenance.done_solicitations_rate')
        ]
        STATUS.each do |status|
          header_row << I18n.t("cooperation_stats_exporter.provenance.#{status}_count")
          header_row << I18n.t("cooperation_stats_exporter.provenance.#{status}_rate")
        end

        sheet.add_row header_row, style: header_style

        # Body
        grouped_solicitations = base_solicitations.select(:id, :provenance_detail)
          .group_by(&:provenance_detail)
          .sort_by { |_, sols| -sols.size }

        grouped_solicitations.each do |provenance_detail, solicitations_array|
          solicitations = Solicitation.where(id: solicitations_array.map(&:id))
          needs = base_needs.joins(:solicitation).where(solicitation: { id: solicitations_array.map(&:id) })

          body_row = [
            provenance_detail,
            solicitations.size,
            solicitations.status_canceled.size,
            calculate_rate(solicitations.status_canceled.size, solicitations),
            needs.size,
            calculate_rate(needs.size, solicitations),
            needs.status_done.size,
            calculate_rate(needs.status_done.size, needs),
            calculate_rate(needs.status_done.size, solicitations)
          ]

          STATUS.each do |status|
            needs_status = needs.send(:"status_#{status}")
            body_row << needs_status.size
            body_row << calculate_rate(needs_status.size, needs)
          end

          sheet.add_row body_row, style: provenance_row_style
        end

        finalise_style
        p 'END PROVENANCE ============================='
      end

      def finalise_style
        # 19 colonne de 15 px
        widths = Array.new(19, 15)
        sheet.column_widths(*widths)

        sheet.add_conditional_formatting('D1:D1000',
          type: :cellIs,
          operator: :greaterThanOrEqual,
          formula: '50%',
          dxfId: @pink,
          priority: 1)

        sheet.add_conditional_formatting('I1:I1000',
          type: :cellIs,
          operator: :lessThanOrEqual,
          formula: '50%',
          dxfId: @yellow,
          priority: 1)

        sheet.add_conditional_formatting('S1:S1000',
          type: :cellIs,
          operator: :greaterThanOrEqual,
          formula: '50%',
          dxfId: @orange,
          priority: 1)
      end

      def provenance_row_style
        row_style = [@label, nil, nil, @rate, nil, @rate, nil, @rate, @rate]
        STATUS.each{ |status| row_style << @count; row_style << @rate }
        row_style
      end

      def header_style
        [@left_header] + Array.new(18, @right_header)
      end
    end
  end
end
