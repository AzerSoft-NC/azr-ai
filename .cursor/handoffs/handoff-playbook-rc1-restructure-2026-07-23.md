# Handoff — Restructuration `playbook-rc1.md` (debug / feature-refactor / test / documentation)

**Date :** 23 juillet 2026
**Repo/fichier concerné :** `docs/agents/playbooks/playbook-rc1.md` (workspace `/home/kako/workspace`)

## Objectif de la session

Retravailler `playbook-rc1.md` pour qu'il organise les best-practices agent par **type de besoin dev** (debug / feature-refactor / test / documentation) au lieu de par skill, en se basant sur les patterns réels observés dans `docs/agents/playbooks/cases/*.md` (14 fiches) et le `README.md` associé — **sans** citer ni lier ces fiches depuis le nouveau document (elles servent uniquement de source empirique).

Méthode utilisée : `/grill-me` en mode caveman ultra, question par question, avant réécriture complète.

## État actuel — fait

`playbook-rc1.md` a été **entièrement réécrit** (overwrite complet, pas un diff). Nouvelle structure :

1. En 30 secondes (routing workspace, quasi inchangé)
2. Setup minimal avant de coder avec un agent
3. Boucle quotidienne (ajout de l'étape « identifier le type de besoin »)
4. **Recettes par type de besoin** (nouveau cœur du doc) :
   - 4.1 Debug (runtime **+** schéma/SQL fondus ensemble — même pattern hypothèses classées H1..Hn)
   - 4.2 Feature / Refactor (flux unique, 2 points de départ : ticket vs audit)
   - 4.3 Test (critère de fin explicite + mock minimal + décision Git squash/`--no-ff`)
   - 4.4 Documentation (doc = code live, découpe par concept, garde-fou scope creep sur `/commit`)
5. Recettes transversales (déplacées ici, hors des 4 besoins) : Commit assisté / Handoff / Plateforme workspace / Nouveau skill
6. Scénarios bout-en-bout — réécrits, 1 scénario générique par catégorie (A Debug, B Feature/Refactor, C Test, D Documentation)
7. Aide-mémoire prompts (inchangé)
8. Checklist « session propre » (+ ligne « type de besoin identifié »)
9. Limites (inchangé)

L'ancienne section « Ce que les études de cas montrent » (chiffres de sessions, liens vers `pitch/`) a été **supprimée** — jugée incompatible avec l'objectif « cheat sheet best-practices » découplée des cas.

## Décisions verrouillées pendant le grill (ne pas rouvrir sans raison)

| Sujet | Décision |
| --- | --- |
| Schéma/SQL | Fondu dans **debug**, pas de 5e catégorie |
| Recettes transversales | Section à part (§5), pas répétées dans chaque recette besoin |
| Section chiffres/cas (§7 ancienne) | Supprimée |
| Scénarios bout-en-bout | Réécrits génériques, 1 par catégorie (plus les 4 anciens scénarios liés à des histoires précises) |
| Flavor exemples | **Gardé** CAFAT/JBoss/AMQ (pas de généricisation totale vers placeholders neutres) |
| Contenu des recettes | Synthèse généralisée des patterns observés, **aucun** nom de fiche/cas cité dans le doc |
| Feature vs Refactor | 1 seul flux, différence de point de départ documentée en 2 lignes (pas 2 sous-recettes complètes) |
| Titre | Titre principal gardé, sous-titre changé en « cheat sheet par type de besoin » |

## Point d'attention à vérifier en premier la prochaine session

Un `git status` à la racine `/home/kako/workspace` a montré **tout** `docs/agents/playbooks/` (README.md, les 14 fiches `cases/*.md`, et `playbook-rc1.md`) comme **deleted** en unstaged changes — alors que ces fichiers existent bien sur disque (lus/édités sans erreur pendant la session). Cause non investiguée (l'utilisateur a interrompu les commandes shell de diagnostic). Hypothèses possibles à vérifier :
- Root du repo git différent de ce qu'on pense (worktree, symlink, ou `docs/` monté depuis un autre repo).
- Repo `/home/kako/workspace` != repo réel où vivent ces fichiers (peut-être un autre repo imbriqué, cf. `projects/ai-skills/`, `projects/s-rec-dec-impl/` etc. comme sous-repos séparés).

**Ne pas commit/push tant que ce point n'est pas clarifié** — risque de committer une suppression involontaire de 15 fichiers.

## Hors-scope de cette session

- `docs/agents/playbooks/README.md` et les fiches `cases/*.md` : **non modifiés** dans cette session (le rundown pairs par cas reste séparé du cheat sheet best-practices).
- L'utilisateur a indiqué vouloir retravailler `playbook-rc1.md` lui-même ensuite — cette session a posé une base restructurée, pas une version finale figée.

## Suggested skills pour la suite

- `/diagnose` — si la prochaine étape est d'élucider l'anomalie git status (fichiers "deleted" alors que présents sur disque) avant tout commit.
- `/grill-me` — si l'utilisateur veut encore trancher le contenu détaillé d'une des 4 recettes (ex. affiner les anti-patterns ou le prompt type) plutôt que de le faire seul.
- `/commit` — uniquement une fois l'anomalie git clarifiée et le contenu de `playbook-rc1.md` validé par l'utilisateur.
