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

    sh "PGPASSWORD=#{pw} pg_dump --no-owner --no-acl e_conseils_2947 > tmp/export.pgsql  -h localhost -p 10000 -U e_conseils_2947"

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
    whitelisted_models = [Antenne, Institution, Commune, Landing, LandingTopic, Territory, Theme, Subject]

    default_mapping = {
      'content' => -> { Faker::Lorem.paragraph },
      'description' => -> { Faker::Lorem.paragraph },
      'title' => -> { Faker::Lorem.sentence },
      'expert_full_name' => -> { Faker::Name.name },
      'full_name' => -> { Faker::Name.name },
      'phone_number' => -> { Faker::PhoneNumber.phone_number },
      'expert_institution_name' => -> { Faker::Company.name },
      'name' => -> { Faker::Company.name },
      'label' => -> { Faker::Lorem.word },
      'current_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
      'last_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
      'email' => -> { Faker::Internet.email },
      'query' => -> { Faker::Lorem.word },
      'role' => -> { Faker::Job.title },
      'readable_locality' => -> { Faker::Address.postcode + ' ' + Faker::Address.city },
      'siren' => -> { Faker::Company.french_siren_number },
      'siret' => -> { Faker::Company.french_siret_number }
    }

    custom_mapping = {
      # Institution and Antenne names must be unique
      Institution => { 'name' => -> { Faker::Company.name + ' ' + Faker::Number(digits: 3) } },
      Antenne => { 'name' => -> { Faker::Company.name + ' ' + Faker::Number(digits: 3) } },
      # ExpertSubject role must be kept; don’t set this in default
      ExpertSubject => { 'role' => -> (record) { record.role } },
    }

    models = ApplicationRecord.descendants - whitelisted_models

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

        record.save!(validate: false) # We will always have some baddata in production
      end
    end
  end

  task all: %i[dump import anonymize]
end

desc 'import anonymized production data in development db'
task import_dump: %w[import_dump:all db:seed]
