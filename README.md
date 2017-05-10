# e-conseils

Réseau e-conseils : Apporter l'ensemble des aides publiques aux entreprises qui en ont besoin.<br />
[Voir sur le site de beta.gouv.fr](https://beta.gouv.fr/startup/e-conseils.html)

From now on, we're gonna switch in english. 🇬🇧

## Getting started

1. Clone the repository.

        $ git clone git@github.com:sgmap/e-conseils.git
        $ cd e-conseils

2. Install ruby using **rvm**. See `Gemfile` file to know which ruby version is needed.

        $ rvm install x.x.x

3. Install a PostgreSQL database.

        $ brew install postgres

4. Update the `config/database.yml` file (development and test sections) with how you've setup postgres.

5. Install gems with bundler.

        $ gem install bundler
        $ bundle install

6. Execute database configurations.

        $ rake db:create db:schema:load db:migrate
        $ rake db:create db:schema:load db:migrate RAILS_ENV=test

7. Configure Git to prepend commits with branch name.

        $ curl https://gist.githubusercontent.com/jvenezia/57673140506ae9e330c2/raw/bff6973325b159254a3ba13c5cb9ac8fda8e382b/prepare-commit-msg.sh -o .git/hooks/prepare-commit-msg
        $ chmod +x .git/hooks/prepare-commit-msg

8. You can now start a server.

        $ foreman start
    And yay! Check out [this page](http://localhost:3000)!
    
## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.