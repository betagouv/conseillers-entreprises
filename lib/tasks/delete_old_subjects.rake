task update_old_subjects_needs: :environment do
  # One-shot task for #1883.

  puts 'Updating old subjects needs'

  Subject.transaction do
    subjects_count = 0
    needs_count = 0
    default_subject = Subject.find(59)
    subjects = Subject.is_archived.joins(:theme).joins(:needs).where(themes: { id: 11 }).group(:id).having('COUNT(needs.id) < 15')
    subjects.each do |subject|
      subject.needs.each do |need|
        need.subject = default_subject
        if Need.where(subject: default_subject, diagnoses: need.diagnosis).any?
          new_diagnosis = need.diagnosis.dup
          new_diagnosis.step = :not_started
          new_diagnosis.needs = []
          new_diagnosis.save
          need.diagnosis = new_diagnosis
        end
        need.save(validate: false)
        needs_count += 1
      end
      subjects_count += 1
    end
    puts "…updated #{subjects_count} subjects and  #{needs_count} needs"
  end
end
