task create_support_skills: :environment do
  ActiveRecord::Base.transaction do
    theme = Theme.create!(label: "Support",
                          interview_sort_order: Theme.ordered_for_interview.last.interview_sort_order + 1)
    subject = Subject.create!(theme: theme, label: "Support", is_support: true)
    Skill.create!(subject: subject, title: "Relais local")
    Skill.create!(subject: subject, title: "Équipe Place des entreprises")
  end
end
