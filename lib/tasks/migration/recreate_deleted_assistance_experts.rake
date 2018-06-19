# frozen_string_literal: true

task recreate_deleted_assistance_experts: :environment do
  matches = Match.where(assistances_experts_id: nil)
              .where.not(assistance_title: ['', nil])
              .where.not(expert_full_name: ['', nil])
  puts "Il y en a #{matches.count}"
  matches.each do |match|
    experts = Expert.where("experts.first_name || ' ' || experts.last_name = ?", match.expert_full_name)
    if experts.count > 1
      puts "#{match.id} - Too many experts"
      next
    end
    expert = experts.first
    assistance = Assistance.joins(:assistances_experts).where(title: match.assistance_title)
                           .group('assistances.id').select('assistances.*').order('COUNT(*) DESC').first
    if !assistance
      puts "#{match.id} - #{match.assistance_title} - Assistance not found"
      next
    end

    assistance_expert = AssistanceExpert.find_or_create_by!(assistance: assistance, expert: expert)
    match.update! assistances_experts_id: assistance_expert.id
  end
  matches = Match.where(assistances_experts_id: nil)
              .where.not(assistance_title: ['', nil])
              .where.not(expert_full_name: ['', nil])
  puts "Il en reste #{matches.count}"
  array = matches.map(&:id)
  print array
end
