## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* [Gotchas & tips (fr)](05-gotchas.md)
* ➡ [Maintenance (fr)](06-maintenance.md)

# Conseillers-Entreprises - Mise en maintenance

La mise en maintenance du site se fait via Baleen.

## Redirection vers une page de maintenance

- Se connecter sur Baleen, et vérifier qu'on est bien sur l'application "Conseillers-Entreprises"
- Créer une nouvelle règle de redirection (“Personnaliser votre trafic” > “Règles de redirection”) : 
  - rediriger `/` vers `https://redirect.conseillers-entreprises.service-public.fr/ `
  - Cocher "Redirection temporaire" et supprimer les "Query strings"

Pour désactiver le mode maintenance, il suffit de supprimer la règle de redirection.