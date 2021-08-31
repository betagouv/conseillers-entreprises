namespace :import_prod_to_staging do
  # Il peut arriver qu'un tunnel SSH ait été ouvert, non fermé et bloque tout de manière invisible.
  # Pour le tuer, même s'il est en arrière plan : killall scalingo

  def export_filename
    @export_filename ||= 'tmp/export_prod.dump'
  end

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
    db_url = "postgres://#{username}:#{pw}@127.0.0.1:10000/#{dbname}?sslmode=require"

    sh "pg_dump --clean --if-exists --format c --dbname #{db_url} --file #{export_filename}"
    kill_prod_tunnel
  end

  task :import_to_staging do
    setup_staging_tunnel

    sleep 2

    env = `scalingo -a reso-staging env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    username = 'reso_stagin_1257'
    dbname = 'reso_stagin_1257'
    db_url = "postgres://#{username}:#{pw}@127.0.0.1:10000/#{dbname}?sslmode=require"

    # solution non pérenne mais on n'a pas mieux pour le moment
    # sh "echo \"DROP TABLE public.needs CASCADE;\" | psql -d #{db_url}"
    sh "pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname #{db_url} #{export_filename}"

    kill_staging_tunnel
  end

  task all: %i[dump_prod import_to_staging]
end

desc 'import production data in staging db'
task import_prod_to_staging: %w[import_prod_to_staging:all db:seed]
