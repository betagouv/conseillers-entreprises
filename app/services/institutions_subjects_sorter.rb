module InstitutionsSubjectsSorter
  # Sort institution_subjects, themes with cooperation or territorial zones appear last,
  # then sort alphabetically by theme label, then by subject label.
  def sorted_institutions_subjects(institution_subjects)
    institution_subjects.sort { |a, b| compare_institution_subjects(a, b) }
  end

  private

  def compare_institution_subjects(a, b)
    result = special_theme?(a.theme) <=> special_theme?(b.theme)
    result = a.theme.label <=> b.theme.label if result == 0
    result = a.subject.label <=> b.subject.label if result == 0
    result
  end

  def special_theme?(theme)
    theme.territorial_zones.present? || theme.cooperation? ? 1 : 0
  end
end
