## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)
* ➡ [Gotchas & tips (fr)](05-gotchas.md)
* [Maintenance (fr)](06-maintenance.md)

# Conseillers-Entreprises - Gotchas & Tips

## Limitations RNE

Pour rappel, les limitations de l'API RNE : 

- Un blocage du compte lors de 5 tentatives avec un mauvais de mot de passe (c’est ce point qui vous a bloqué)
- Une limitation à un quota de 10 000 appels/jour, en cas de dépassement vous recevez une erreur indiquant le dépassement, mais vous pouvez vous reconnecter le lendemain
- Une limitation système sur l’IP qui limite à 180 appels par minute par IP et qui bannit 10 minutes
- Une limitation sur le nombre d’authentification à 5 authentification toutes les 30 secondes et qui bannit 10 minutes

Parfois, l'API RNE rejette sans motif apparent nos identifiants. Il faut alors les renouveler sur   https://procedures.inpi.fr 
