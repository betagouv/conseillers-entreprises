desc 'move expert to user on feedbacks'
task expert_to_user_for_feedbacks: :environment do
  puts "Avant : #{Feedback.where(user: nil).joins(:expert).count} commentaires sans utilisateur"

  team_pde = Expert.find(500)
  pde_user = User.find(373)
  Feedback.where(feedbackable_id: nil).destroy_all

  single_user_feedbacks = Feedback.where(user: nil).select { |x| x.expert.users.count == 1 }
  single_user_feedbacks.each { |f| f.update(user: f.expert.users.first) }

  many_users_feedbacks = Feedback.where(user: nil)
  many_users_feedbacks.each do |f|
    if f.expert == team_pde
      f.update(user: pde_user)
      next
    end
    f.expert.users.each do |user|
      if user.full_name.parameterize == f.expert.full_name.parameterize
        f.update(user: user)
        break
      end
    end
    next unless f.user.nil?

    users_created_before = f.expert.users.where('created_at < ?', f.created_at)
    if users_created_before.count == 1
      f.update(user: users_created_before.first)
    end
  end

  puts "Après : #{Feedback.where(user: nil).joins(:expert).count} commentaires sans utilisateur"
end
