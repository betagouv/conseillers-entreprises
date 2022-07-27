namespace :import_dump do
  def setup_tunnel
    tunnel_command = 'scalingo -a reso-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_tunnel
    Process.kill('QUIT', @tunnel_pid)
  end

  task :dump do
    setup_tunnel

    sleep 2

    env = `scalingo -a reso-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    dbname = 'reso_produc_4107'

    sh "PGPASSWORD=#{pw} pg_dump --no-owner --no-acl #{dbname} > tmp/export.pgsql  -h localhost -p 10000 -U #{dbname}"

    kill_tunnel
  end

  task :import do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    dbuser = YAML.load_file('config/database.yml').dig('development', 'username')

    sh "psql place-des-entreprises-development -f tmp/export.pgsql -U #{dbuser}"

    sh 'rm tmp/export.pgsql'

    Rake::Task['db:migrate'].invoke

    Rake::Task['db:environment:set'].invoke('RAILS_ENV=development')
  end

  task anonymize: :environment do
    allowed_models = [InstitutionSubject, Logo, Category, Badge, Antenne, Institution, Commune, Landing, LandingTheme, LandingSubject, LandingJointTheme, Territory, Theme, Subject]

    Expert.where(email: nil).update_all(email: 'no@email.com')
    User.where(email: nil).update_all(email: 'no@email.com')

    default_mapping = {
      'content' => -> { Faker::Lorem.paragraph },
      'description' => -> { Faker::Lorem.paragraph },
      'title' => -> { Faker::Lorem.sentence },
      'full_name' => -> { Faker::Name.name },
      'phone_number' => -> { Faker::PhoneNumber.phone_number },
      'name' => -> { Faker::Company.name },
      'label' => -> { Faker::Lorem.word },
      'current_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
      'last_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
      'email' => -> { Faker::Internet.email },
      'query' => -> { Faker::Lorem.word },
      'job' => -> { Faker::Job.title },
      'readable_locality' => -> { Faker::Address.postcode + ' ' + Faker::Address.city },
      'siren' => -> { Faker::Company.french_siren_number },
      'siret' => -> { Faker::Company.french_siret_number }
    }

    custom_mapping = {
      # Institution and Antenne names must be unique
      Institution => { 'name' => -> { Faker::Company.name + ' ' + Faker::Number(digits: 3) } },
      Antenne => { 'name' => -> { Faker::Company.name + ' ' + Faker::Number(digits: 3) } },
      # ExpertSubject job must be kept; don’t set this in default
      ExpertSubject => { 'job' => -> (record) { record.job } },
      Expert => {
        'email' => -> (record) do
          # Match single user names with their expert name
          email = Faker::Internet.email
          record.users.where(email: record.email).update_all(email: email)
          email
        end,
        'full_name' => -> (record) do
          # Give cool names to teams
          full_name = record.team? ? Faker::Team.name : Faker::Name.name
          record.users.where(email: record.email).update_all(full_name: full_name)
          full_name
        end,
      },
      User => {
        # Users’ emails and full_names are changed with their experts
        # (each user has a personal_skillset expert)
        'email' => -> (record) { record.email },
        'full_name' => -> (record) { record.full_name }
      }
    }

    models = ApplicationRecord.descendants - allowed_models

    models.sort_by(&:to_s).each do |model|
      mapping = default_mapping
        .merge(custom_mapping[model] || {})
        .filter{ |attribute| attribute.in? model.attribute_names }
      next if mapping.empty?

      puts "#{model} #{model.all.count} #{mapping.keys}"

      model.find_each do |record|
        mapping.each do |attribute, block|
          new_value = block.arity == 0 ? block.call : block.call(record)
          record[attribute] = new_value
        end

        record.save!(touch: false, validate: false) # Don’t change timestamps; don’t validate because there can only be some baddata in production
      end
    end
  end

  task all: %i[dump import anonymize]
end

desc 'import anonymized production data in development db'
task import_dump: %w[import_dump:all db:seed]
