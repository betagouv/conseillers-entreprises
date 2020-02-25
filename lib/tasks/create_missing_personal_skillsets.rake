desc 'create personal skillsets for users missing it'
task create_missing_personal_skillsets: :environment do
  User.transaction do
    users_with_personal_skillsets = User.not_deleted.joins(:experts).merge(Expert.personal_skillsets)
    users_without_personal_skillsets = User.not_deleted.where.not(id: users_with_personal_skillsets)
    puts "Before: #{users_without_personal_skillsets.count} users without skillset"
    users_without_personal_skillsets.each do |user|
      user.create_personal_skillset_if_needed
    end
    puts "After: #{users_without_personal_skillsets.count} users without skillset"
  end
end
