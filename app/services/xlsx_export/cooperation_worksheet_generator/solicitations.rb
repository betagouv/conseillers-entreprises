module XlsxExport
  module CooperationWorksheetGenerator
    class Solicitations < Base
      def generate
        sheet.add_row

        ## Transmission
        sheet.add_row [
          Solicitation.human_attribute_name(:id),
          Solicitation.human_attribute_name(:siret),
          Solicitation.human_attribute_name(:matches),
          Solicitation.human_attribute_name(:badges),
          Solicitation.human_attribute_name(:theme),
          Solicitation.human_attribute_name(:subject),
          Need.human_attribute_name(:status)
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header, @right_header]

        base_solicitations.find_each do |solicitation|
          sheet.add_row([
            solicitation.id,
            solicitation.siret,
            solicitation.matches.present?,
            solicitation.badges.pluck(:title).uniq.join(' '),
            solicitation.theme.label,
            solicitation.subject.label,
            solicitation.needs.pluck(:status).uniq.map{ Need.human_attribute_value(:status, it) }.join(' '),
          ])
        end

        finalise_style
      end

      def finalise_style
        [
          'A1:G1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 20, 20, 20, 20, 20, 20, 20
      end
    end
  end
end
