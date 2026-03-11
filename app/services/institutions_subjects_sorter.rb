module InstitutionsSubjectsSorter
  # Sort institutions_subjects themes with cooperation or territorial zones appear last
  def sorted_institutions_subjects(institution_subjects)
    institution_subjects.sort_by do |is|
      theme = is.theme
      [theme.territorial_zones.present? || theme.cooperation? ? 1 : 0, theme.label, is.subject.label]
    end
  end
end
