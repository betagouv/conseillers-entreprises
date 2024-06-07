## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* ➡ [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* [Gotchas & tips (fr)](05-gotchas.md)
* [Maintenance (fr)](06-maintenance.md)

# Deployment

## Domain name

The `service-public.fr` is registered on NAMESHIELD by the DILA, the `conseillers-entreprises` subdomain is delegated to the team on OVH. This allows us to manage TXT records ourselves and to add additional sub-subdomains. Contact the developer team to access the OVH account.

## Branches and setup

Conseillers-entreprises.service-public.fr is deployed on [Scalingo](http://doc.scalingo.com/languages/ruby/getting-started-with-rails/), with two distinct environment, `ce-staging` and `ce-production.` 

* `ce-staging` is served at https://ce-staging.scalingo.io.
* `ce-production` is the actual https://conseillers-entreprises.service-public.fr

There are GitHub to Scalingo hooks setup for auto-deployment:
* The `main` branch is automatically deployed to the `ce-staging` env.
* The `production` branch is automatically deployed to the `ce-production` env.

Additionally, a `postdeploy` hook [is setup in the Procfile](https://doc.scalingo.com/platform/app/postdeploy-hook#applying-migrations) so that Rails migrations are run automatically.

In case of emergency, you can always run the rails console in production using the `scalingo` command line tool.

    $ scalingo -a ce-staging run rails c
    $ scalingo -a ce-production run rails c

## Waf

Conseillers-Entreprises is protected behind a French WAF solution : [Baleen](https://baleen.cloud/)

## HSTS

HTTP Strict Transport Security is enabled in the app config (`config.force_ssl = true`) ; it’s disabled in the Scalingo settings, otherwise it duplicates the value in the header, which is invalid. Although browsers seem to tolerate it, security checks like [Mozilla Observatory](https://observatory.mozilla.org/analyze/conseillers-entreprises.service-public.fr) complain about it.

## Server unavailable

In case of a server problem, website traffic can be redirected to [redirect.conseillers-entreprises.service-public.fr](https://redirect.conseillers-entreprises.service-public.fr) (source code : [github.com/betagouv/conseillers-entreprises-redirect](https://github.com/betagouv/conseillers-entreprises-redirect)).

## Release

Use `rake push_to_production` to review the changes before pushing to production:

```
$ rake push_to_production
Updating main and production…
Last production commit is ebe7d79c4149c3ae64af917e0ccd09bb7c473cc8
About to merge 5 PRs and push to production:
🚀
* [#718](https://github.com/betagouv/conseillers-entreprises/pull/718) display created_at date instead of visit date
* [#720](https://github.com/betagouv/conseillers-entreprises/pull/720) Bump rack from 2.0.7 to 2.0.8
* [#714](https://github.com/betagouv/conseillers-entreprises/pull/714) Do not cc everyone in UserMailer#match_feedback
* [#710](https://github.com/betagouv/conseillers-entreprises/pull/710) Send a distinct email to the advisor when sending notifications
* [#713](https://github.com/betagouv/conseillers-entreprises/pull/713) Redesign email css
Proceed?
```

Make sure these are the changes you expect to push to production.
* there may be substantial changes that require deeper testing;
* it’s ok to push small changes often;
* some changes may require a new environment variable to be defined, or some data might be manually migrated;
* let the team know about the impending release on the team discussion interface.

```
y
Basculement sur la branche 'production'
Done!
```

## Rollback

Reverting a deployment (rollback) is as easy as releasing:
* `git revert` the commit(s), or the merge commit(s) that need to be rolled back
* setup a new pull request with these reverts
* push to production as usual.

---

Next: [Architecture](04-architecture.md)
