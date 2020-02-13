namespace :diagnoses_flag do
  task add: :environment do
    User.without_experts.each { |x| x.update(can_view_diagnoses_tab: true) }
  end
end

desc 'add can_view_diagnoses_tab flag to users without expert'
task diagnoses_flag: %w[diagnoses_flag:add]
