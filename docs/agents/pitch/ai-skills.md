# Étude de cas — `ai-skills`

**En date du :** 22 juillet 2026  
**Période observée :** 25 juin 2026 → 15 juillet 2026  
**Volume :** ~8 sessions agent (fusion des ouvertures Cursor sur le dépôt skills et sous-dossiers associés)

## Rôle du workspace

Dépôt de **compétences agent** (skills) : modes de travail réutilisables (conception grillée, commits, communication condensée, etc.). Volume faible, signal fort : ici l’IA ne produit pas le logiciel métier — elle **fabrique le mode opératoire** qui accélère tous les autres workspaces.

## Types d’usage dominants


| Type d’activité                           | Ordre de grandeur |
| ----------------------------------------- | ----------------- |
| Skills / mode opératoire                  | ~60 %             |
| Infra / outillage (auth Git, accès dépôt) | ~25 %             |
| Hygiène Git / commits                     | ~15 %             |


## Arcs de période

### Fin juin — Amorçage des rituels

Mise en place et premiers usages de skills transverses (communication condensée, assistance aux commits). L’objectif n’est pas un livrable métier, mais une **convention d’équipe machine**.

### Mi-juillet — Affinage et friction d’accès

Édition ciblée de skills (ex. grille de conception qui écrit dans un dossier `context/`, format de messages de commit aligné sur une convention d’équipe). En parallèle, résolution de frictions **Git / Bitbucket** (authentification, clés) pour que le dépôt skills reste poussable sans friction quotidienne.

## Pratiques notables (généralisables)

- **Externaliser les rituels** : ce qui se répète (commit, challenge de design, format de réponse) devient un skill versionné, pas un prompt collé à la main.
- **Traiter le mode opératoire comme un produit** : petit dépôt, revue, itération — même discipline que le code applicatif.
- **Séparer méta et métier** : les skills vivent hors de `s-rec-dec-impl`, donc réutilisables par d’autres équipes / dépôts.
- **Débloquer l’accès tôt** : sans auth Git fluide, le catalogue de skills ne se partage pas.

## Ce que ça illustre pour une autre équipe

Investir un peu de temps dans un **catalogue de skills** multiplie le rendement des sessions métier. 

Le ROI n’apparaît pas dans le volume de chats de ce dépôt, mais dans la **répétabilité** observée ailleurs (commits assistés, grill de conception, styles de dialogue stables).

Pour généraliser à l’échelle CAFAT : partir de 3–5 rituels d’équipe, les versionner, les documenter en une page, puis les étendre seulement quand la douleur revient.