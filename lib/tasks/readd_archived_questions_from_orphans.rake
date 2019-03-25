task readd_archived_questions_from_orphans: :environment do
  # A temporary script to cleanup some baddata
  orphaned_needs = DiagnosedNeed.where(question: nil)
  orphans_by_question = orphaned_needs.to_a.group_by(&:question_label)
  now = Time.zone.now
  category = Category.last # the last by interview order is the “other” category
  orphans_by_question.each do |label, needs|
    puts "Question #{label}: #{needs.count}"
    Question.create(label: label, archived_at: now, category: category, diagnosed_needs: needs)
  end
end
