class AddUserLastActiveAt < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_active_at, :datetime, null: true

    up_only do
      puts "Compute initial values for last_active_at…"
      max_feedbacks_updated_ats = User.not_deleted
        .joins(:feedbacks).group("users.id")
        .pluck("users.id, MAX(feedbacks.updated_at)").to_h

      max_matches_updated_ats = Expert.joins(:users, :received_matches)
        .group("experts.id")
        .having("COUNT(users.id)=1")
        .where.not(matches: { status: :quo })
        .pluck(Arel.sql("(array_agg(users.id))[1], MAX(matches.updated_at)")).to_h

      last_active_ats = max_feedbacks_updated_ats.merge(max_matches_updated_ats) { |_k, a, b| [a, b].max }
      users = User.where(id: last_active_ats.keys).select(:id)

      bar = ProgressBar.new(last_active_ats.count)

      users.find_each do |user|
        user.update_columns(last_active_at: last_active_ats[user.id], touch: true)
        bar.increment!
      end
      puts "Done"
    end
  end
end
