## Documentation

* ➡ [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* [Gotchas & tips (fr)](05-gotchas.md)
* [Maintenance (fr)](06-maintenance.md)

# Setup a development environment

## Getting started

1. Clone the repository.

        $ git clone git@github.com:betagouv/conseillers-entreprises.git
        $ cd conseillers-entreprises

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

6. … and yarn

        $ npm install --global yarn
        $ yarn install

7. Create `.env` file from `.env.example`, and ask the team to fill it in.

        $ cp .env.example .env

8. Execute database configurations for development and test environments.

        $ rake db:create db:schema:load
        $ rake db:create db:schema:load RAILS_ENV=test
        $ rake parallel:create # for parallel

9. You can now start the web server and the jobs task.

        $ gem install foreman
        $ foreman start --procfile=Procfile.dev

    Website is now [running locally](http://localhost:3000)!

## GitGuardian on pre-commit

To prevent secrets from being pushed to the repository, we use [GitGuardian](https://www.gitguardian.com/). It is configured to run on pre-commit.
To use it you need to install the GitGuardian CLI:

1. Install the GitGuardian CLI: https://docs.gitguardian.com/ggshield-docs/getting-started
    
2. Authenticate the CLI and follow the instructions
          
       $ ggshield auth login

3. Make sure you have the pre-commit framework installed:

        $ pip install pre-commit

4. Install the pre-commit hooks:

        $ pre-commit install --hook-type pre-push

---

Next: [Development](02-development.md)
