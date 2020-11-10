task fix_flags_values: :environment do
  # One-shot task for #1389. Delete once it’s run in production.
  #
  # This does two things:
  # * ensure flags are boolean
  # * disable User.can_view_review_subjects_flash and Expert.can_edit_own_subjects for everyone.

  users = User.where.not(flags: {})
  puts "Fixing #{users.size} users flags"
  users.each do |user|
    user.fix_flag_values
    user.can_view_review_subjects_flash = false
    user.save!(touch: false, validate: false)
    print '.'
  end
  puts

  experts = Expert.where.not(flags: {})
  puts "Fixing #{experts.size} experts flags"
  experts.each do |expert|
    expert.fix_flag_values
    expert.can_edit_own_subjects = false
    expert.save!(touch: false, validate: false)
    print '.'
  end
  puts

  puts 'Done'
end
