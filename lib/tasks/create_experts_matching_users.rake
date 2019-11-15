# Create users for experts with no user. See Expert#create_matching_user!
task :create_experts_matching_users do
  Expert.without_users.each do |expert|
    expert.create_matching_user!
  end
end
