module XlsxExport
  class PanierCritiqueExporter < BaseExporter
    def initialize
      @critical_rate_experts = PositionningRate::Collection.new(Expert.active).send(:critical_rate).includes(:antenne, :reminder_feedbacks).most_needs_quo_first
    end

    # TODO A déporter dans controller + enregistrement cloud
    def generate_file
      filename = "#{I18n.t('panier_critique_exporter.file_name')}-#{Time.zone.now.iso8601}.xlsx"

      User.find(2010).xls_exports.attach(io: xlsx.to_stream(true),
                                         key: "xls_exports/panier_critique/#{filename}",
                                         filename: filename,
                                         content_type: 'application/xlsx')
    end

    def xlsx
      p = Axlsx::Package.new
      wb = p.workbook
      create_styles wb.styles

      wb.add_worksheet(name: I18n.t('panier_critique_exporter.worksheet_title')) do |sheet|
        sheet.add_row [
          I18n.t('attributes.full_name'),
          I18n.t('attributes.email'),
          I18n.t('attributes.expert'),
          I18n.t('attributes.expert_email'),
          I18n.t('attributes.expert_antenne'),
          I18n.t('attributes.antenne_region'),
        ], style: @first_row_style

        @critical_rate_experts.each do |e|
          antenne = e.antenne
          e.users.each do |u|
            sheet.add_row [
              u.full_name,
              u.email,
              e.full_name,
              e.email,
              antenne.name,
              antenne.regions&.first&.name
            ]
          end
        end
      end

      p.use_shared_strings = true
      p
    end

    def create_styles(s)
      @first_row_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, bg_color: 'f1efeb', sz: 12, b: true, border: { style: :thin, color: '6a6a6a' }
      @align_center = s.add_style alignment: { horizontal: :left, vertical: :center, wrap_text: true }
      @gray_bg = s.add_style alignment: { horizontal: :left, vertical: :center, wrap_text: true }, bg_color: 'f1f1f1', border: { style: :thin, color: 'A7A7A7' }
      s
    end
  end
end
