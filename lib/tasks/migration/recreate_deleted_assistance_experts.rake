# frozen_string_literal: true

task recreate_deleted_assistance_experts: :environment do
  saes = SelectedAssistanceExpert.where(assistances_experts_id: nil)
                                 .where.not(assistance_title: ['', nil])
                                 .where.not(expert_full_name: ['', nil])
  puts "Il y en a #{saes.count}"
  saes.each do |sae|
    experts = Expert.where("experts.first_name || ' ' || experts.last_name = ?", sae.expert_full_name)
    if experts.count > 1
      puts "#{sae.id} - Too many experts"
      next
    end
    expert = experts.first
    assistance = Assistance.joins(:assistances_experts).where(title: sae.assistance_title)
                            .group('assistances.id').select('assistances.*').order('COUNT(*) DESC').first
    unless assistance
      puts "#{sae.id} - #{sae.assistance_title} - Assistance not found"
      next
    end

    assistance_expert = AssistanceExpert.find_or_create_by!(assistance: assistance, expert: expert)
    sae.update! assistances_experts_id: assistance_expert.id
  end
  saes = SelectedAssistanceExpert.where(assistances_experts_id: nil)
                                 .where.not(assistance_title: ['', nil])
                                 .where.not(expert_full_name: ['', nil])
  puts "Il en reste #{saes.count}"
  array = saes.map(&:id)
  print array
end
