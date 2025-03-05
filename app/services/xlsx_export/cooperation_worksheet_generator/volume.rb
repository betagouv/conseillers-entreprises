module XlsxExport
  module CooperationWorksheetGenerator
    class Volume < Base
      def generate
        sheet.add_row

        ## Transmission
        #
        add_header_row('volume.transmitted_header')

        # Besoins détectés
        sheet.add_row [
          I18n.t('cooperation_stats_exporter.detected_solicitations'),
          base_solicitations.size,
          '1'
        ], style: count_rate_row_style
        # Besoins transmis
        count = base_solicitations.joins(:diagnosis).merge(Diagnosis.completed).size
        add_status_row(:transmitted, count, base_solicitations)

        sheet.add_row

        ## Positionnement
        #
        add_header_row('volume.positionning_header')
        add_status_row(:transmitted, base_needs.size, base_needs)
        add_status_row(:not_status_quo, base_needs.not_status_quo.size, base_needs)
        add_status_row(:status_not_for_me, base_needs.where(status: :not_for_me).size, base_needs)
        add_status_row(:taken_care_of, base_needs.not_status_quo.where.not(status: :not_for_me).size, base_needs)
        add_status_row(:status_done, base_needs.where(status: :done).size, base_needs)
        add_status_row(:status_done_no_help, base_needs.where(status: :done_no_help).size, base_needs)
        add_status_row(:status_done_not_reachable, base_needs.where(status: :done_not_reachable).size, base_needs)
        add_status_row(:status_taking_care, base_needs.where(status: :taking_care).size, base_needs)
        add_status_row(:status_quo, base_needs.where(status: :quo).size, base_needs)

        finalise_style
      end

      def finalise_style
        [
          'A1:C1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 15
      end
    end
  end
end
