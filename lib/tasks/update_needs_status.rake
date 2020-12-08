task update_needs_status: :environment do
  # One-shot task for #1417. Delete once it’s been run in production.
  #
  # This reruns Need#update_status for all needs, without updating the dates.

  puts 'Updating needs'

  Need.transaction do
    total = 0
    Need.all
      .preload(:diagnosis, :matches)
      .find_each do |need|
      old_status = need.status.to_sym
      new_status = need.computed_status
      if old_status != new_status
        puts "#{need.id}(#{need.created_at.to_date}): #{old_status} -> #{new_status} #{need.matches.pluck(:status)}"
        need.status = new_status
        need.save!(touch: false, validate: false)
        total += 1
      end
    end

    puts "…updated #{total} needs"
  end
end
