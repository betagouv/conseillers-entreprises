# Réso

Apporter l'ensemble des aides publiques aux entreprises qui en ont besoin. [reso.beta.gouv.fr](https://reso.beta.gouv.fr/)

Créé dans le contexte de [l'incubateur des startups d'état](https://beta.gouv.fr/).

From now on, we're gonna switch in English. 🇬🇧

## Getting started

1. Clone the repository.

        $ git clone git@github.com:betagouv/reso.git
        $ cd reso

2. Install Ruby using **rvm**. See `Gemfile` file to know which Ruby version is needed.

        $ brew install rvm
        $ rvm install x.x.x

3. Install PostgreSQL and create a user if you don't have any.

        $ brew install postgres

    Create a PostgreSQL user (replace `my_username` and `my_password`).

        $ psql -c "CREATE USER my_username WITH PASSWORD 'my_password';"

    Or:

        $ postgres createuser my_username

4. Create `config/database.yml` file from `config/database.yml.example`. Fill development and test sections in the latter with your PostgreSQL username and password.

        $ cp config/database.example.yml config/database.yml

5. Install project dependencies (gems) with bundler.

        $ gem install bundler
        $ bundle

6. Install yarn and use `yarn` command to install JS library dependencies (such as Vue.js).

        $ brew install yarn
        $ yarn

    The project uses Vue.js with Rails 5 [Webpacker](https://github.com/rails/webpacker).

7. Execute database configurations for development and test environments.

        $ rake db:create db:migrate
        $ rake db:create db:migrate RAILS_ENV=test

8. Create `.env` file from `.env.example`, and ask the team to fill it in.

        $ cp .env.example .env

9. Configure Git to prepend commit messages with branch name.

        $ curl https://gist.githubusercontent.com/jvenezia/57673140506ae9e330c2/raw/bff6973325b159254a3ba13c5cb9ac8fda8e382b/prepare-commit-msg.sh -o .git/hooks/prepare-commit-msg
        $ chmod +x .git/hooks/prepare-commit-msg

10. You can now start a server.

        $ gem install foreman
        $ foreman start --procfile=Procfile.dev

    And yay! Reso is now [running locally](http://localhost:3000)!

## Tests

You can run all application tests with `./meta_rake` command. It launches following tests:

- `rake` : Rspec tests
- `npm test` : Jasmine front-end tests
- `rubocop` : Ruby/Rails/Rspec code style
- `npm run linter` : JS code style
- `haml-lint app/views/` : Haml template code style
- `i18n-tasks unused && i18n-tasks missing` : Rails I18n usage

You can run these tests individually.

You may need to install [Node.js](https://nodejs.org/en/download/) for `npm` command.

## Development data

You can import data in your local development database from remote staging database. Staging password will be asked, you can find it in Scalingo dashboard.

Make sure [Scalingo CLI](http://doc.scalingo.com/app/command-line-tool.html) is installed.

1. Recreate your development database: `rake db:drop && rake db:create`
2. Create a tunnel: `scalingo -a reso-staging db-tunnel SCALINGO_POSTGRESQL_URL`
3. Create a database dump: `pg_dump reso_stagin_5827 > tmp/export.pgsql  -h localhost -p 10000 -U reso_stagin_5827 -o`
4. Import the dump in your local development database: `psql reso-development -f tmp/export.pgsql -U postgres`
5. Run migrations: `rake db:migrate && rake db:migrate RAILS_ENV=test`

Make sure data is anonymous to preserve users privacy.

## Staging

A staging environment is available [at this address](http://reso-staging.scalingo.io).

Add staging repository to your git remote configuration:

    $ git remote add scalingo-staging git@scalingo.com:reso-staging.git

In order to deploy the project on staging environment, use:

    $ git push scalingo-staging master

Don't forget to perform database migrations if any:

    $ scalingo -a reso-staging run rails db:migrate

## Emails

Development and staging emails are sent on [Mailtrap](https://mailtrap.io/) in order to test email notifications without sending them to the real users. Ask the team for credentials.

## Deployment / Production

Same logic as staging environment, replacing `-staging` with `-production`.

More information on [Scalingo documentation](http://doc.scalingo.com/languages/ruby/getting-started-with-rails/).

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our git and coding conventions, and the process for submitting pull requests to us.
