module XlsxExport
  # UserExporter supports two options.
  # Both require the relation to be fetched using User.relevant_for_skills.
  # include_expert_team: include the “relevant_expert” team.
  # institutions_subjects: the institutions_subjects to add as csv columns for the relevant expert.
  class UserExporter < BaseExporter
    def fields
      fields = base_fields
      fields.merge!(fields_for_team) if @options[:include_expert_team]
      fields.merge!(fields_for_subjects) if @options[:institutions_subjects]

      fields
    end

    def base_fields
      {
        full_name: :full_name,
        antenne: -> { antenne.name },
        email: :email,
        phone_number: :phone_number,
        job: :job,
      }
    end

    def preloaded_associations
      [
        :antenne
      ]
    end

    def fields_for_team
      {
        team_full_name: -> { relevant_expert.full_name if relevant_expert.team? },
        team_email: -> { relevant_expert.email if relevant_expert.team? },
        team_phone_number: -> { relevant_expert.phone_number if relevant_expert.team? },
        team_custom_communes: -> { relevant_expert.communes.pluck(:insee_code).join(', ') if relevant_expert.custom_communes? },
      }
    end

    def headers
      ['', '', '', I18n.t('export_xls.phone_instructions'), '', I18n.t('export_xls.team_email'), '', '', '', I18n.t('export_xls.subjects_instructions')]
    end

    def fields_for_subjects
      @options[:institutions_subjects].to_h do |institution_subject|
        # We build a hash of <institution subject>: <expert subject>
        # * There can be only one expert_subject for an (expert, institution_subject) pair.
        title = institution_subject.unique_name
        lambda = -> {
          # This block is executed in the context of a User
          # (`self` is a User; See `object.instance_exec(&lambda)` in CsvExport::Base.)

          # We’re using `&` instead of .merge to use the preloaded relations instead of doing a new DB query.
          experts_subjects = relevant_expert.experts_subjects & institution_subject.experts_subjects
          raise 'There should only be one ExpertSubject' if experts_subjects.size > 1
          expert_subject = experts_subjects.first
          expert_subject&.csv_description
        }
        [title, lambda]
      end
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |u| [u.antenne.name, u.relevant_expert&.full_name] }
    end

    def create_styles(s)
      @green_bg = s.add_style bg_color: 'D9EAD3', alignment: { horizontal: :center, vertical: :center, wrap_text: true },
                              border: { style: :thin, color: '000000' }
      @green_bg_bold = s.add_style bg_color: 'D9EAD3', border: { style: :thin, color: 'c6c6c6' },
                                   alignment: { horizontal: :center, vertical: :center, wrap_text: true }, b: true, sz: 13
      @green_bg_italic = s.add_style bg_color: 'D9EAD3',alignment: { horizontal: :center, vertical: :center, wrap_text: true },
                                     height: 50, i: true, sz: 11, border: { style: :thin, color: '000000', edges: [:bottom] }
      @default_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, sz: 11, height: 40,
                                   fg_color: '1F497D', border: { style: :thin, color: '000000', edges: [:bottom] }
      @text_red = s.add_style fg_color: 'C0504D', alignment: { horizontal: :center, vertical: :center, wrap_text: true }
      @first_row_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, height: 70, sz: 11
      @second_row_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, height: 50, b: true, sz: 13
      @third_row_style = s.add_style alignment: { horizontal: :center, vertical: :center, wrap_text: true }, height: 50, i: true, sz: 11,
                                     border: { style: :thin, color: '000000', edges: [:bottom] }
      s
    end

    def build_headers_rows(sheet, attributes, klass)
      # first row
      sheet.add_row(headers, height: 60)
      # second row, columns titles
      sheet.add_row(attributes.keys.map{ |attr| klass.human_attribute_name(attr, default: attr) }, height: 60, widths: [:ignore, :auto,80])
      # third row, institution subject description
      third_row = fields.values
      third_row[0] = ''
      third_row[1] = I18n.t('export_xls.email_instructions')
      third_row[2..4] = third_row[2..4].map { |v| v = '' }
      third_row[5] = I18n.t('export_xls.teams_instructions')
      third_row[6..8] = third_row[6..8].map { |v| v = '' }
      index = 9
      @options[:institutions_subjects].each do |is|
        third_row[index] = is.description
        index += 1
      end
      sheet.add_row(third_row, height: 60)
      sheet
    end

    def build_rows(sheet, attributes)
      # Users lines
      row = attributes.values
      sort_relation(@relation).each do |object|
        sheet.add_row(row.map do |val|
          if val.respond_to? :call
            lambda = val
            object.instance_exec(&lambda)
          else
            object.send(val)
          end
        end, height: 30)
      end
      sheet.rows.each_index do |i|
        case i
        when 0
          sheet.row_style(i, @first_row_style)
        when 1
          sheet.row_style(i, @second_row_style)
        when 2
          sheet.row_style(i, @third_row_style)
        else
          sheet.row_style i, @default_style
          sheet.rows[i].cells[5].style = @green_bg
          sheet.rows[i].cells[6].style = @green_bg
          sheet.rows[i].cells[7].style = @green_bg
          sheet.rows[i].cells[8].style = @green_bg
        end
      end
      sheet
    end

    def apply_style(sheet, attributes)
      # Style
      sheet.merge_cells('A1:C1')
      sheet.merge_cells('F1:I1')
      sheet.merge_cells('B3:E3')
      sheet.merge_cells('F3:I3')
      sheet.merge_cells('J1:L1')
      sheet.rows[0].cells[4].style = @text_red
      sheet.rows[0].cells[8].style = @text_red
      sheet.rows[0].cells[5].style = @green_bg_bold
      sheet.rows[1].cells[5].style = @green_bg_bold
      sheet.rows[1].cells[6].style = @green_bg_bold
      sheet.rows[1].cells[7].style = @green_bg_bold
      sheet.rows[1].cells[8].style = @green_bg_bold
      sheet.col_style 5, @green_bg, row_offset: 2
      sheet.col_style 6, @green_bg, row_offset: 2
      sheet.col_style 7, @green_bg, row_offset: 2
      sheet.col_style 8, @green_bg, row_offset: 2
      sheet.rows[2].cells[5].style = @green_bg_italic

      attributes.keys.each_index do |i|
        width = if i < 9
          40
        else
          25
        end
        sheet.column_info[i].width = width
      end
      sheet
    end
  end
end
