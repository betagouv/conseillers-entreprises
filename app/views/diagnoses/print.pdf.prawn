prawn_document do |pdf|

  pdf.font("#{Rails.root.join('app', 'assets', 'fonts')}/Lato-Regular.ttf")
  pdf.image Rails.root.join('app', 'assets', 'images', 'reso-logo-simple.png'), width: 150
  pdf.text root_url
  pdf.text I18n.l(Date.today)
  pdf.move_down 20

  pdf.text 'Questionnaire en entreprise'
  pdf.move_down 20

  pdf.text '😀'

  pdf.column_box([0, pdf.cursor], columns: 2, width: pdf.bounds.width) do
    @categories_with_questions.each do |item|
      pdf.text item[:category] if item[:category]
      pdf.move_down 15
      item[:questions].each do |question|
        pdf.text question[:label]
        pdf.text question[:institutions_list]
        pdf.move_down 10
      end
      pdf.move_down 20
    end
  end
end