module XlsxExport
  class MatchExporter < BaseExporter
    def fields
      {
        solicitation_created_at: -> { I18n.l(solicitation&.created_at, format: :fr) if solicitation.present? },
        solicitation_id: -> { solicitation&.id },
        solicitation_description: -> { solicitation&.description },
        solicitation_provenance_category: -> { I18n.t(solicitation.provenance_category, scope: %i(solicitation provenance_categories)) if solicitation&.provenance_category.present? },
        solicitation_provenance_title: -> { (solicitation&.provenance_title_sanitized.presence) },
        theme: :theme,
        subject: :subject,
        siret: -> { facility.siret },
        commune: -> { facility.commune },
        facility_regions: -> { facility_regions&.pluck(:name).uniq.join(", ") },
        company_name: -> { company&.name },
        company_forme_exercice: -> {  I18n.t(company&.forme_exercice, scope: 'natures_entreprise', default: '') },
        facility_nature_activites: -> { facility.nature_activites.map{ |nature| I18n.t(nature, scope: 'natures_entreprise') }.join(', ') },
        facility_naf: -> { facility.naf_code },
        facility_nafa: -> { facility.nafa_codes&.join(", ") },
        company_categorie_juridique: -> { company.categorie_juridique },
        company_effectif: -> { Effectif::CodeEffectif.new(facility.displayable_code_effectif).intitule_effectif },
        solicitation_full_name: -> { solicitation&.full_name },
        solicitation_email: -> { solicitation&.email },
        solicitation_phone_number: -> { solicitation&.phone_number },
        match_created_at:  -> { I18n.l(created_at, format: :fr) },
        need_id: -> { need&.id },
        notified_expert: -> { expert&.full_name },
        expert_antenne: :expert_antenne,
        expert_institution: :expert_institution,
        match_status_by_expert: -> { human_attribute_value(:status, context: :short) },
        match_taken_care_of_at: -> { I18n.l(taken_care_of_at, format: :fr) if taken_care_of_at.present? },
        match_closed_at: -> { I18n.l(closed_at, format: :fr) if closed_at.present? },
        global_need_status: -> { need.human_attribute_value(:status, context: :csv) },
        need_url: -> { Rails.application.routes.url_helpers.need_url(need) }
      }
    end

    def preloaded_associations
      [
        diagnosis: :needs
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |u| [u.need.id, u.id] }
    end

    def create_styles(s)
      @first_row_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, bg_color: 'f1efeb', sz: 12, b: true, border: { style: :thin, color: '6a6a6a' }
      @align_center = s.add_style alignment: { horizontal: :left, vertical: :center, wrap_text: true }
      @gray_bg = s.add_style alignment: { horizontal: :left, vertical: :center, wrap_text: true }, bg_color: 'f1f1f1', border: { style: :thin, color: 'A7A7A7' }
      s
    end

    def build_headers_rows(sheet, _, _)
      headers = []
      sort_relation(@relation)
      fields.each_key do |field|
        headers << I18n.t(field, scope: :attributes)
      end
      sheet.add_row(headers, height: 60)

      sheet
    end

    def build_rows(sheet, attributes)
      row = attributes.values
      count_rows = 1
      count_needs = 0
      @relation.order(:created_at).group_by { |m| m.need.id }.each_value do |matches|
        count_needs += 1
        matches.each do |object|
          sheet.add_row(row.map do |val|
            if val.respond_to? :call
              lambda = val
              object.instance_exec(&lambda)
            else
              object.send(val)
            end
          end, height: 30)
          sheet.rows[count_rows].style = if count_needs.even?
            @gray_bg
          else
            @align_center
          end
          count_rows += 1
        end
      end
      sheet
    end

    def apply_style(sheet, _)
      sheet.rows[0].style = @first_row_style
      sheet.sheet_view.pane do |pane|
        pane.top_left_cell = "A2"
        pane.state = :frozen_split
        pane.y_split = 1
        pane.x_split = 0
        pane.active_pane = :bottom_right
      end
      sheet
    end
  end
end
