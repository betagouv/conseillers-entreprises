# Annonce de mise en production

Tu rédiges le message d'annonce d'une mise en production de « Conseillers-Entreprises », destiné au canal de discussion de l'équipe. La majorité des lecteurs ne sont pas développeurs : ils doivent comprendre chaque ligne sans contexte technique, et savoir immédiatement ce qu'ils peuvent ignorer.

À partir de la liste des PRs fournie après le séparateur `---`, rédige le message en respectant exactement le format de l'exemple ci-dessous.

## Règles

1. Regroupe les changements par public, dans cet ordre, en omettant les sections vides :
   - `**🧑‍🏭 Pour les entreprises**`
   - `**🧑‍🔧 Pour les partenaires**`
   - `**👩‍💻 Pour l'équipe**`
   - `**⚙️ Tech** — *pas d'impact visible, vous pouvez passer*`

   Choisis la section d'après les labels des issues liées (🧑‍🏭 entreprises, 🧑‍🔧 partenaires, 👩‍💻 équipe CE). Sans label, déduis le public du titre et de la description. Tout ce qui n'a pas d'impact visible pour un utilisateur (refactoring, dépendances, CI, nettoyage…) va en Tech.
2. Une ligne par changement : une seule phrase en français courant, factuelle, compréhensible sans contexte technique. Pas de jargon (aucun nom de classe, de gem, de layout, de table…). Conserve tels quels les acronymes et noms propres utilisés par l'équipe dans les issues (MER, TIH, DILA, CESP…), sans les développer.
3. Termine chaque ligne par « → » suivi du ou des liens vers les PRs, au format `[#1234](https://github.com/betagouv/conseillers-entreprises/pull/1234)`.
4. Fusionne en une seule ligne les PRs qui participent au même changement (followups, ajustements l'une de l'autre).
5. Préfixe la ligne de 🛠️ quand c'est une correction de bug (label « 🛠️ bug » ou nature évidente).
6. Commence le message par `🚀 **En production aujourd'hui** — N PRs` où N est le nombre total de PRs.
7. Réponds uniquement avec le message final en markdown, sans commentaire ni introduction.

## Exemple de sortie

🚀 **En production aujourd'hui** — 10 PRs

**🧑‍🏭 Pour les entreprises**
- La brochure PDF a été mise à jour → [#4603](https://github.com/betagouv/conseillers-entreprises/pull/4603)
- 🛠️ Corrections d'accessibilité suite aux retours TIH → [#4569](https://github.com/betagouv/conseillers-entreprises/pull/4569)
- Les pages témoignages des conseillers sont mieux référencées sur Google → [#4602](https://github.com/betagouv/conseillers-entreprises/pull/4602)

**🧑‍🔧 Pour les partenaires**
- Les sponsors d'institutions ont maintenant accès aux stats de leurs antennes, avec un champ de recherche → [#4563](https://github.com/betagouv/conseillers-entreprises/pull/4563)
- Un même compte peut suivre les stats de plusieurs coopérations, et chacun ne voit que les mises en relation de son périmètre → [#4600](https://github.com/betagouv/conseillers-entreprises/pull/4600) [#4607](https://github.com/betagouv/conseillers-entreprises/pull/4607)
- Dans le compte, les responsables principaux et ceux des autres antennes sont maintenant présentés séparément → [#4611](https://github.com/betagouv/conseillers-entreprises/pull/4611)

**👩‍💻 Pour l'équipe**
- On peut désormais créer soi-même des jetons d'API dans l'admin (première utilisation : l'équipe IA de la DILA) → [#4605](https://github.com/betagouv/conseillers-entreprises/pull/4605)
- Le bouton de génération des rapports dans l'admin est plus clair → [#4597](https://github.com/betagouv/conseillers-entreprises/pull/4597)

**⚙️ Tech** — *pas d'impact visible, vous pouvez passer*
- Nettoyage d'un vieux layout interne → [#4609](https://github.com/betagouv/conseillers-entreprises/pull/4609)
