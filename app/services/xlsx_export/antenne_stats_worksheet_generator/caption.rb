module XlsxExport
  module AntenneStatsWorksheetGenerator
    class Caption < Base
      def initialize(sheet, antenne, styles)
        @antenne = antenne
        @sheet = sheet
        create_styles styles
      end

      def generate
        sheet.add_row

        sheet.add_row [I18n.t('antenne_stats_exporter.done_caption_label'), I18n.t('antenne_stats_exporter.done_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.done_not_reachable_caption_label'), I18n.t('antenne_stats_exporter.done_not_reachable_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.done_no_help_caption_label'), I18n.t('antenne_stats_exporter.done_no_help_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.taking_care_caption_label'), I18n.t('antenne_stats_exporter.taking_care_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.not_for_me_caption_label'), I18n.t('antenne_stats_exporter.not_for_me_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.quo_caption_label'), I18n.t('antenne_stats_exporter.quo_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.positionning_caption_label'), I18n.t('antenne_stats_exporter.positionning_caption_definition')], style: caption_row_style
        sheet.add_row [I18n.t('antenne_stats_exporter.positionning_accepted_caption_label'), I18n.t('antenne_stats_exporter.positionning_accepted_caption_definition')], style: caption_row_style
        sheet.add_row

        finalise_style
      end

      # Style
      #
      def caption_row_style
        [@bold, nil]
      end

      def finalise_style
        [
          'A1:B1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 30, 150
      end
    end
  end
end
