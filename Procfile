web: bundle exec puma -C config/puma.rb
clock: bundle exec clockwork app/models/clockwork.rb
delayedjob: bin/delayed_job run

postdeploy: bundle exec rake db:migrate
backup-builpack: bin/pg-backup.sh
