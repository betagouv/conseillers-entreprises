namespace :migration do
  desc 'Run long migration in background'
  task run_territories: :environment do
    puts "Starting migration MigrateTerritoriesToTerritorialZones..."
    
    # Run only this specific migration
    migration_version = '20250123141418'
    
    # Check if migration has already run
    if ActiveRecord::Base.connection.select_value("SELECT version FROM schema_migrations WHERE version = '#{migration_version}'")
      puts "Migration #{migration_version} already executed."
    else
      require Rails.root.join('db/migrate/20250123141418_migrate_territories_to_territorial_zones.rb')
      MigrateTerritoriesToTerritorialZones.new.up
      
      # Mark migration as completed
      ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{migration_version}')")
      puts "Migration #{migration_version} completed."
    end
    
    # Run remaining migrations
    puts "Running remaining migrations..."
    Rake::Task['db:migrate'].invoke
  end
end