web: bundle exec puma -C config/puma.rb
log: tail -f log/development.log
webpack: ./bin/webpack-dev-server

postdeploy: bundle exec rake db:migrate