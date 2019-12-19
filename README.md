# Place des Entreprises

Apporter l’ensemble des aides publiques aux entreprises qui en ont besoin. [place-des-entreprises.beta.gouv.fr](https://place-des-entreprises.beta.gouv.fr/)

Créé dans le contexte de [l’incubateur des startups d’état](https://beta.gouv.fr/).

## Getting started

1. Clone the repository.

        $ git clone git@github.com:betagouv/place-des-entreprises.git
        $ cd place-des-entreprises

2. Install Ruby using **rbenv**. See `.ruby-version` file to know which Ruby version is needed.

        $ brew install rbenv
        $ rbenv install

3. Install PostgreSQL and create a user if you don’t have any.

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

6. Execute database configurations for development and test environments.

        $ rake db:create db:schema:load
        $ rake db:create db:schema:load RAILS_ENV=test

7. Create `.env` file from `.env.example`, and ask the team to fill it in.

        $ cp .env.example .env

8. You can now start a server.

        $ gem install foreman
        $ foreman start --procfile=Procfile.dev

    And yay! Place des Entreprises is now [running locally](http://localhost:3000)!

## Tests

- `bin/rspec` : Rspec tests
- `rake lint`:
  - `rake lint:rubocop` : ruby files code style
  - `rake lint:haml` : haml files code style 
  - `rake lint:i18n` : i18n missing/unused keys and formatting
  - `rake lint:brakeman` : static analysis security vulnerability 

## Browser compatibility

Supported browsers: recent versions of Firefox, Chrome, Safari, Edge or IE11.

Compatibility is tested with Browserstack.<br/>
[<img src="doc/browserstack-logo-600x315.png" width="200">](https://www.browserstack.com/)

## Development data

You can import data in your local development database from remote staging database. See the [official documentation](https://doc.scalingo.com/platform/databases/access), Make sure [Scalingo CLI](http://doc.scalingo.com/app/command-line-tool.html) is installed.

- `rake import_dump`:
 - `rake import_dump:dump` : dump data from scalingo 
 - `rake import_dump:import` : drop local db and import
 - `rake import_dump:anonymize` : anonymize personal information fields

## Emails

Development emails are visible locally via [letter_opener_web](http://localhost:3000/letter_opener) 
Staging emails are sent on [Mailtrap](https://mailtrap.io/) in order to test email notifications without sending them to the real users.

## Deployment

### Branches and setup

Place des Entreprises is deployed on [Scalingo](http://doc.scalingo.com/languages/ruby/getting-started-with-rails/), with two distinct environment, ``reso-staging`` and `reso-production.

* `reso-staging` is served at https://reso-staging.scalingo.io.
* ``reso-production`` is the actual https://place-des-entreprises.beta.gouv.fr

GitHub->Scalingo hooks are setup for auto-deployment:
* The `master` branch is automatically deployed to the `reso-staging` env.
* The `production` branch is automatically deployed to the `reso-production` env.  

Additionally, a `postdeploy` hook [is setup in the Procfile](https://doc.scalingo.com/platform/app/postdeploy-hook#applying-migrations) so that Rails migrations are run automatically.  

In case of emergency, you can always run rails migrations manually using the `scalingo` command line tool.
    
    $ scalingo -a reso-staging run rails db:migrate
    $ scalingo -a reso-production run rails db:migrate 

### rake push_to_production`
``
Use `rake push_to_production` to review the changed before pushing to production:
```
$ rake push_to_production
Updating master and production…
Last production commit is ebe7d79c4149c3ae64af917e0ccd09bb7c473cc8
About to merge 5 PRs and push to production:
🚀 
* [#718](https://github.com/betagouv/place-des-entreprises/pull/718) display created_at date instead of visit date
* [#720](https://github.com/betagouv/place-des-entreprises/pull/720) Bump rack from 2.0.7 to 2.0.8
* [#714](https://github.com/betagouv/place-des-entreprises/pull/714) Do not cc everyone in UserMailer#match_feedback
* [#710](https://github.com/betagouv/place-des-entreprises/pull/710) Send a distinct email to the advisor when sending notifications
* [#713](https://github.com/betagouv/place-des-entreprises/pull/713) Redesign email css
Proceed?
y
Basculement sur la branche 'production'
Done!
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our git and coding conventions, and the process for submitting pull requests to us.
