## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* ➡ [Déployer une région (fr)](05-deployer-une-region.md)

# Déployer une région

Procédure vouée à disparaître une fois le produit lancé nationalement.

Un script à modifier à chaque déploiement peut être lancé pour automatiser le déploiement via `rake deploy_region`.

Le fichier à modifier se trouve ici : `/lib/tasks/deploy_region.rake`

## 1. Code région

Rechercher le `code_region`, qui figure dans `/config/locales/data/codes_regions.fr.yml`.

```ruby
code_region = 2
```

## 2. Référent région

Rechercher le référent Place des Entreprises à affecter au territoire. C'est ce référent qui sera indiqué comme contact support dans les mails concernant les demandes du territoire.

```ruby
ref = User.find_by(email: 'adeline.latron@beta.gouv.fr')
```

## 3. Création / mise à jour de la région

- créer ou mettre à jour le territoire :

```ruby
region = Territory.where(code_region: option[:code_region]).first_or_initialize
region.update(
  name: 'Martinique',
  bassin_emploi: false,
  deployed_at: "2021-06-10".to_datetime,
  support_contact_id: ref.id
  ]
```

## 4. Mise à jour des institutions

Les conseils régionaux sont liés aux régions. Ces institutions doivent donc aussi être mises à jour.

```ruby
institution = Institution.where(slug: "collectivite_de_martinique").first_or_initialize
institution.update(code_region: code_region)
```







