namespace :migrate_skills_to_institutions do
  task :move_skills => :environment do
    Expert.transaction do
      Expert.find_each do |expert|
        expert.skills.each do |skill|
          institution_subject = InstitutionSubject.find_or_initialize_by(institution: expert.institution,
                                                                         subject: skill.subject,
                                                                         description: skill.title)
          ExpertSubject.find_or_initialize_by(expert: expert, institution_subject: institution_subject).save!
        end
      end
    end
  end

  task :add_subject_to_matches => :environment do
    default_subject = Subject.find_by!(label: "Autre besoin non référencé")
    Match.find_each do |match|
      if match.skill.nil?
        find_skill = Skill.find_by(title: match.skill_title)
        if find_skill.nil?
          subject = default_subject
        else
          subject = find_skill.subject
        end
      else
        subject = match.skill.subject
      end
      match.subject = subject
      match.save!
    end
  end

  task all: %i[move_skills add_subject_to_matches]
end

desc 'move expert skills to institutions'
task migrate_skills_to_institutions: %w[migrate_skills_to_institutions:all]
