prawn_document do |pdf|
  pdf.font_families.update(
    'Lato' => {
      normal: "#{Rails.root.join('app', 'assets', 'fonts')}/Lato-Regular.ttf",
      bold: "#{Rails.root.join('app', 'assets', 'fonts')}/Lato-Bold.ttf"
    }
  )

  pdf.font('Lato', size: 10)

  pdf.image Rails.root.join('app', 'assets', 'images', 'reso-logo-simple.png'), width: 150

  header_width = 140
  pdf.text_box root_url, at: [pdf.bounds.width - header_width, pdf.bounds.top - 10], width: header_width
  pdf.text_box(I18n.t('diagnoses.print.creation_date', date: I18n.l(Date.today)),
               at: [pdf.bounds.width - header_width, pdf.bounds.top - 23], width: header_width)

  pdf.move_down 20

  pdf.font('Lato', style: :bold, size: 24) do
    pdf.text I18n.t('diagnoses.print.title')
  end

  pdf.move_down 8

  @categories_with_questions.each do |item|
    pdf.move_down 12

    pdf.font('Lato', style: :bold, size: 15) do
      pdf.text item[:category] if item[:category]
    end

    item[:questions].each do |question|
      institutions_list_text = ''
      if question[:institutions_list].present?
        institutions_list_text = I18n.t('diagnoses.print.institution_example', institution_list_string: question[:institutions_list])
      end

      question_data = [[question[:label], "<font size='10'>#{institutions_list_text}</font>"]]

      pdf.font('Lato', size: 12) do
        cell_style = { borders: [], inline_format: true, width: (pdf.bounds.width / 2) }
        pdf.table(question_data, cell_style: cell_style)
      end

      pdf.font('Lato', size: 10) do
        points = [[' . ' * 80], [' . ' * 80], [' . ' * 80]]
        cell_style = { borders: [],
                       overflow: :shrink_to_fit,
                       width: pdf.bounds.width,
                       single_line: true,
                       padding: [5, 0, 0, 10] }
        pdf.table(points, cell_style: cell_style)
      end
    end

    pdf.move_down 10
  end
end