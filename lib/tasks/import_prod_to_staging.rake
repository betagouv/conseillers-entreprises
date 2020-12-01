namespace :import_prod_to_staging do
  EXPORT_FILENAME = 'tmp/export_prod.dump'

  def setup_prod_tunnel
    tunnel_command = 'scalingo -a reso-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @prod_tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_prod_tunnel
    Process.kill('QUIT', @prod_tunnel_pid)
  end

  def setup_staging_tunnel
    tunnel_command = 'scalingo -a reso-staging db-tunnel SCALINGO_POSTGRESQL_URL'
    @staging_tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_staging_tunnel
    Process.kill('QUIT', @staging_tunnel_pid)
  end

  task :dump_prod do
    setup_prod_tunnel

    sleep 2

    env = `scalingo -a reso-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    username = 'reso_produc_4107'
    dbname = 'reso_produc_4107'
    sh "#{pg_url}"
    db_url = "postgres://#{username}:#{pw}@127.0.0.1:10000/#{dbname}?sslmode=require"

    sh "pg_dump --clean --if-exists --format c --dbname #{db_url} --file #{EXPORT_FILENAME}"
    kill_prod_tunnel
  end

  task :import_to_staging do
    setup_staging_tunnel

    sleep 2

    env = `scalingo -a reso-staging env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    username = 'reso_stagin_5607'
    dbname = 'reso_stagin_5607'
    db_url = "postgres://#{username}:#{pw}@127.0.0.1:10000/#{dbname}?sslmode=require"

    # solution non pérenne mais on n'a pas mieux pour le moment
    sh "echo \"DROP TABLE public.needs CASCADE;\" | psql -d #{db_url}"
    sh "pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname #{db_url} #{EXPORT_FILENAME}"

    kill_staging_tunnel
  end

  task all: %i[dump_prod import_to_staging]
end

desc 'import production data in staging db'
task import_prod_to_staging: %w[import_prod_to_staging:all db:seed]
