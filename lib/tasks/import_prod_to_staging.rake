namespace :import_prod_to_staging do
  # Il peut arriver qu'un tunnel SSH ait été ouvert, non fermé et bloque tout de manière invisible.
  # Pour le tuer, même s'il est en arrière plan : killall scalingo

  # Documentation : https://doc.scalingo.com/databases/postgresql/dump-restore

  def pgsql_filename
    @pgsql_filename ||= 'tmp/export_prod.pgsql'
  end

  def setup_prod_tunnel
    tunnel_command = 'scalingo --region osc-secnum-fr1 -a ce-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @prod_tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_prod_tunnel
    Process.kill('QUIT', @prod_tunnel_pid)
  end

  def setup_staging_tunnel
    tunnel_command = 'scalingo -a ce-staging db-tunnel SCALINGO_POSTGRESQL_URL'
    @staging_tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_staging_tunnel
    Process.kill('QUIT', @staging_tunnel_pid)
  end

  task :dump_prod do
    setup_prod_tunnel

    sleep 2

    env = `scalingo --region osc-secnum-fr1 -a ce-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    username = pg_url[/\/\/(.*):.*@/,1]
    dbname = username
    database_url = "postgresql://#{username}:#{pw}@127.0.0.1:10000/#{dbname}"

    sh "pg_dump --clean --if-exists --format c --dbname #{database_url} --no-owner --no-privileges --no-comments --exclude-schema 'information_schema' --exclude-schema '^pg_*' --file #{pgsql_filename}"

    kill_prod_tunnel
  end

  task :import_to_staging do
    setup_staging_tunnel

    sleep 2

    env = `scalingo -a ce-staging env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    username = pg_url[/\/\/(.*):.*@/,1]
    dbname = username
    database_url = "postgresql://#{username}:#{pw}@127.0.0.1:10000/#{dbname}"

    sh "pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname #{database_url} #{pgsql_filename}"

    kill_staging_tunnel
  end

  task all: %i[dump_prod import_to_staging]
end

desc 'import production data in staging db'
task import_prod_to_staging: %w[import_prod_to_staging:all anonymize:all db:seed staging:transform_data_for_demo]
