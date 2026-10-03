# Playbook agentique — cheat sheet par type de besoin

**Public :** développeurs / collègues techniques
**En date du :** 23 juillet 2026

Ce document indique *comment faire*, organisé par **type de besoin dev** (debug, feature/refactor, test, documentation) plutôt que par skill.

---

## En 30 secondes

### Règle d'or

- **humain =** quoi + validation
- **agent =** comment + exploration

> ⚠️ Pas de « refais tout le module » sans critère de fin.

## Checklist « session propre »

- [ ] `/caveman` en court
- [ ] Bon workspace ouvert
- [ ] Type de besoin identifié (debug / feature-refactor / test / documentation)
- [ ] Critère de fin écrit
- [ ] Doc de domaine pointée si sujet métier
- [ ] Skill choisi (ou choix explicite de ne pas en prendre)
- [ ] Diffs petits + re-test
- [ ] Rien de secret dans les docs / prompts / handoffs
- [ ] `/handoff` si le fil n'est pas clos

> ⚠️ Anti-pattern : coller un stacktrace de 200 lignes sans dire ce que tu as déjà tenté.
---

## Boucle quotidienne (template)

```
1. Intention     → 1 phrase + critère de fin
2. Besoin        → debug | feature-refactor | test | documentation (§4)
3. Skill?        → systematic-debugging | grill-me | (rien)
4. Itération     → petit diff → re-test → feedback
5. Livraison     → /commit (après ton OK)
6. Transmission  → /handoff si incomplet
```

---

## Recettes par type de besoin

> ℹ️ `/grill-me` n'est pas réservé au feature-refactor 
>
> Dès qu'une décision est structurante (design, gouvernance Git, périmètre doc), elle doit être **tranchée avant** de continuer, quel que soit le besoin.
> `/grill-me` permet de la documenté

### Debug (runtime, données, schéma)

**Quand :** stacktrace / crash runtime, comportement observé ≠ attendu.

**Skill :** `systematic-debugging` (vendored superpowers) — se déclenche sur tout bug, test rouge ou comportement inattendu.

**Étapes (pattern observé) :**

1. Reproduis / colle le symptôme exact : commande, stacktrace ou erreur SQL, **court** (tronque avec marqueur si long).
2. Précise déjà tenté + contrainte de mode si besoin (« ask before doing anything » = pas de code sans ton go).
3. Exige des **hypothèses classées** (H1, H2, H3… par plausibilité) plutôt qu'un verdict unique immédiat ; tu élimines avec ton savoir métier / contexte ops (ex. un refresh de base récent tranche en faveur d'une hypothèse).
4. Distingue **bruit outil** vs **vraie cause** (ex. warning client SQL, erreur de parsing d'un runner ≠ erreur moteur).
5. Un changement à la fois → **boucle de re-test réelle** (redeploy, rejouer un message, requête de contrôle) avant d'empiler une autre hypothèse.
6. Vérifie l'**effet domino** : le même défaut touche-t-il d'autres classes / tables / consumers du même type ? Généralise si oui (script réutilisable plutôt que fix ponctuel).
7. Si le fix marche : capitalise dans `CONTEXT.md` / une note courte (comportement legacy, piège d'outil) + `/commit` thématique.

**Prompt type :**

```text
systematic-debugging

Symptôme : <stacktrace ou erreur, 15-30 lignes max>
Attendu : <comportement normal>
Déjà tenté : <ce qui a été exclu>
Contexte : <ex. refresh de base récent, redeploy, rewrite en cours>

Critère de fin : <ex. déploiement OK + message de test consommé>
Ask before doing anything. Propose hypothèses classées avant de coder.
```

**Anti-patterns :**

- « Fix ça » sans log ni critère de fin.
- Sauter aux hypothèses sans boucle de re-test (discussion théorique ≠ diagnostic).
- Traiter un warning outil (ex. 0 ligne affectée) comme une panne applicative sans vérifier.
- Corriger un symptôme sans vérifier si d'autres objets similaires ont le même défaut.

---

### Feature / Refactor (domaine → code)

**Quand :** nouvelle règle métier à livrer (ticket/spec) **ou** suspicion de code mort / classe trop grosse à assainir (audit). 

- **Feature** part d'un ticket/spec : nouvelle entité, nouveau service, capture d'écran de spec.
- **Refactor** part d'un audit : « je pense que seul X est utilisé, vérifie » avant de proposer un plan.

**Skills :** `/grill-me` avant d'implémenter ou si le vocabulaire dérive.

**Étapes (pattern observé) :**

1. Cadre le point de départ : ticket/spec en langage métier (feature) **ou** demande de cartographie complète des usages réels d'une classe/champ (refactor) — jamais de code avant cette étape.
2. Lance `/grill-me` : une question à la fois, réponse recommandée par l'agent, toi qui arbitres et tranches les contradictions plan/code/doc.
3. Matérialise un **plan de suivi** : phases numérotées, cases à cocher par étape, règle explicite « confirmation avant chaque commit » **scopée au plan**, pas une règle globale de l'agent.
4. Mets à jour `CONTEXT.md` / ADR dès qu'un terme ou une décision structurante (ex. stéréotype d'injection, découpage de classe) est tranché — pas en fin de sprint (normalement géré par `/grill-me`)
5. Implémente **par tranches testables** en suivant le plan tel quel (« implémente le plan, ne le modifie pas, ne recrée pas les todos ») ; chaque tranche → re-test avant la suivante.
6. Pour un découpage de classe (god class → orchestrateur + workers) : fais lister par l'agent ce qui est partagé vs spécifique avant de générer les nouvelles classes.
7. `/commit` par intention/tranche (pas un commit fourre-tout « domaine + schéma + UI »).

**Prompt type :**

```text
Besoin : <feature: résumé ticket en langage métier>
       ou <refactor: "je soupçonne que seul X est utilisé dans <classe>, fais une cartographie complète (lu / persisté / transmis)">
Contrainte : rester cohérent avec CONTEXT.md et le code existant.
À la fin : plan d'implémentation en phases + cases à cocher ; vocabulaire tranché dans CONTEXT si besoin.
Ne code pas tant que le plan n'est pas validé.

/grill-me
```

**Anti-patterns :**

- Coder pendant qu'un terme métier (ex. « annulation ») veut encore dire 2-3 choses différentes.
- Supprimer un champ « visiblement mort » sans avoir vérifié persistance/transmission.
- Une règle de confirmation-avant-commit posée comme règle globale de l'agent au lieu d'une règle de plan.
- Un seul commit géant qui mélange plusieurs tranches du plan.

---

### Test

**Quand :** réécriture de suite legacy (setup lourd, mocks multiples) vers un style plus strict, ou décision sur la gouvernance Git d'une branche de tests.

**Skill :** en général aucun skill dédié ; `/grill-me` seulement si la stratégie Git devient une vraie décision produit.

**Étapes (pattern observé) :**

1. Donne un **critère de fin explicite** sur l'assertion (ex. « vérifie juste que la réponse n'est pas nulle, pas son contenu ») — évite un test qui fige trop un comportement métier encore mouvant.
2. Précise le **périmètre de mock minimal** (« mock seulement X », pas toutes les couches) ; recoupe avec les autres tests du module pour rester cohérent.
3. Une fois la suite verte, traite la **stratégie d'historique Git** comme une vraie décision, pas un détail : `--no-ff` (garder les commits intermédiaires) vs squash (arbre propre) — trancher **avant** de pousser sur une branche partagée.
4. Si rewrite d'historique nécessaire après coup : uniquement sur branche pas encore partagée avec l'équipe, jamais force-push sur une branche partagée sans coordination (`--force-with-lease` sur les branches feature perso).

**Prompt type :**

```text
Réécris <test> en <style cible, ex. Mockito pur>.
Vérifie seulement : <flux attendu, ex. lecture contexte/DB → logique métier → save → réponse non nulle>.
Ne teste pas le contenu de <partie encore mouvante>.
Mock minimal : seulement <dépendance nécessaire>.
```

**Anti-patterns :**

- Assertion trop stricte sur un comportement métier qui va encore bouger.
- Sur-mock de couches déjà couvertes par d'autres tests du module.
- Décider squash/`--no-ff` après avoir déjà poussé sur une branche partagée (retour en arrière coûteux).
- Force-push sur une branche partagée sans accord explicite.

---

### Documentation

**Quand :** doc qui a pris du retard sur le code, doc à structurer pour un nouveau public (ex. pairs vs direction), historique de changement à extraire.

**Skill :** aucun skill dédié pour la rédaction ; `/commit` pour la livraison finale, en restant strict sur son périmètre.

**Étapes (pattern observé) :**

1. Pars du **code / état réel actuel**, pas d'un inventaire théorique de ce qui « devrait » être documenté (« j'ai beaucoup changé, revois la doc » + fichier(s) concerné(s) en contexte).
2. Fais lister par l'agent les **lacunes** au-delà de la demande initiale (workflow manquant, glossaire à jour) avant de trancher le périmètre.
3. **Découpe par concept métier** plutôt qu'un seul pavé — un fichier par concept, un README/index qui pointe vers chacun.
4. Externalise l'historique / changelog dans un fichier dédié (`PATCH_NOTES.md` ou équivalent) plutôt que de le garder en tête du README principal.
5. Au moment du `/commit` : reste en alerte sur le **scope creep** — un skill de commit sert à lire le diff et proposer un message, pas à corriger des fichiers « au passage » sans que tu l'aies demandé. Si ça arrive, signale-le immédiatement et fais choisir (revert / garder / inclure explicitement).
6. Exige un message de commit complet dans **un seul bloc code**, copiable tel quel.

**Prompt type :**

```text
@<doc existante ou périmètre>
J'ai beaucoup changé <domaine>, revois la doc pour qu'elle reflète le code actuel.
Qu'est-ce que tu vois d'autre à documenter ?
Découpe par concept si le sujet est large ; crée un index si plusieurs fichiers.
```

**Anti-patterns :**

- Documenter depuis la mémoire du dernier rework plutôt que depuis le code live.
- Un seul fichier monolithe qui mélange plusieurs concepts métier distincts.
- Laisser un skill `/commit` élargir le diff sans le signaler.
- Message de commit éclaté en plusieurs blocs / hors bloc code.

---

## Recettes transversales

Indépendantes du type de besoin (§4) ; s'appliquent aux quatre.

### Commit assisté

**Quand :** working tree prêt, intention claire, tu veux le format d'équipe.

**Skill :** `/commit` (éventuellement `/commit FIX MEA-123`).

**Étapes :**

1. `git status` / diff dans ta tête : **un** sujet.
2. Invoque `/commit` ; lis le message proposé (TYPE, SCOPE, why + bullets).
3. Corrige le fond si besoin ; **approuve** avant le `git commit`.
4. Si le hook refuse : corrige, **nouveau** commit (pas d'amend sauvage).

**Prompt type :**

```text
/commit FIX MEA-878

Un seul sujet : <résumé>.
N'inclus pas les fichiers non liés au sujet.
```

**Anti-patterns :** laisser committer secrets / `.env` ; amalgamer refactor + fix + docs sans lien ; laisser l'agent éditer du contenu non demandé pendant un `/commit`.

### Handoff (soir / collègue / autre machine)

**Quand :** fil long, contexte chaud, tu reprendras plus tard — ou quelqu'un d'autre reprend.

**Skill :** `/handoff` + une phrase sur la suite.

**Étapes :**

1. Décide la **prochaine** session (« finir conso AMQ », « trancher préliste »…).
2. `/handoff <objectif suite>`.
3. Vérifie le fichier : objectif, état, hors-scope, skills suggérés, pas de secrets.
4. Au prochain démarrage : attache le handoff (`@…`) et continue.

**Prompt type :**

```text
/handoff reprendre demain : rejouer un message de test sur le conso CDI
après le dernier fix de déploiement. Ne pas toucher au schéma SQL.
```

**Anti-patterns :** handoff = dump du chat entier ; chemins home / mots de passe ; todo flou (« continuer »).



### Plateforme workspace (`prj` / `srv` / images)

**Quand :** Maven lent, image JBoss trop lourde, `srv init` / pins `dockers.conf`, onboarding CLI.

**Où :** Cursor ouvert sur la **racine** workspace (pas dans `projects/<app>`).

**Étapes :**

1. Reproduis la commande qui casse (`prj start`, `srv …`).
2. Pointe `docs/usage.md` / `docs/structure.md` / `config/dockers.conf`.
3. Demande un fix **script + doc** ensemble (sinon le prochain collègue retombe).
4. Valide sur un second projet si le changement est transverse.
5. Commit côté workspace (scripts/docs trackés ; pas `projects/`*).

**Prompt type :**

```text
`prj start` sur un projet Merlin échoue après le build au moment du déploiement.
On est à la racine workspace. Lis docs/usage.md et le script concerné.
Propose le plus petit correctif + une ligne de doc si le contrat de « started »
(`.deployed`) n'est pas clair. Pas de changement dans le code métier du projet.
```

**Anti-patterns :** patcher un Dockerfile « pour mon laptop » sans pin ; mélanger fix plateforme et commit métier dans le même fil.



### Nouveau skill (rituel d'équipe)

**Quand :** tu retapes le même prompt 3× (commit, grill, style de réponse, checklist revue…).

**Où :** dépôt skills (hors repos métier).

**Étapes :**

1. Nomme le déclencheur (« quand je dis X, l'agent fait Y »).
2. Écris un `SKILL.md` minimal : description, when to use, steps, exemplesm dans une branche
3. Teste sur un vrai fil métier.
4. Itère ; ne grossis le skill que si la douleur revient.
5. Commit / push la branche et creer une pull request.

**Prompt type :**

```text
Crée un skill `/revue-pr` qui : résume le diff, liste les risques runtime
JBoss/AMQ, vérifie la présence de docs/CONTEXT si le domaine a bougé.
Style impératif court. Pas de génération de code dans ce skill.
```

**Anti-patterns :** 15 skills avant d'en utiliser 3 ; skill métier collé dans un repo applicatif (non partageable).

---

## 6. Scénarios bout-en-bout

### Scénario A — Debug (crash runtime)


| Étape | Qui         | Action                                                                    |
| ----- | ----------- | ------------------------------------------------------------------------- |
| 1     | Toi         | Symptôme observé (`.failed`, stacktrace, erreur SQL) ; copies l'essentiel |
| 2     | Toi → agent | Prompt                                                                    |
| 3     | Agent       | Hypothèses classées (H1, H2, H3…)                                         |
| 4     | Toi         | Tu élimines celles que ton contexte ops invalide déjà                     |
| 5     | Agent       | Patch minimal + consignes de re-test                                      |
| 6     | Toi         | Re-test ; critère de fin atteint                                          |
| 7     | Toi         | `/commit` + note courte si le piège est récurrent (`CONTEXT.md`)          |


### Scénario B — Feature/Refactor (besoin métier flou → code)


| Étape | Qui         | Action                                                                    |
| ----- | ----------- | ------------------------------------------------------------------------- |
| 1     | Toi         | Besoin en 5 lignes (ticket) ou suspicion (audit), sans solution technique |
| 2     | Toi → agent | `/grill-me` (§4.2)                                                        |
| 3     | Duo         | Terme ou frontière de classe tranché                                      |
| 4     | Agent       | MAJ `CONTEXT.md` ; plan en phases + cases à cocher                        |
| 5     | Duo         | Tu valides l'ordre des phases                                             |
| 6     | Agent       | Implémentation tranche 1 + tests / rejeu                                  |
| 7     | Toi         | `/commit` par tranche ; `/handoff` si fin de journée                      |


### Scénario C — Test (legacy → suite ciblée)


| Étape | Qui   | Action                                                               |
| ----- | ----- | -------------------------------------------------------------------- |
| 1     | Toi   | Critère de fin explicite (« flux OK, pas contenu ») + périmètre mock |
| 2     | Agent | Réécriture ciblée, mock minimal                                      |
| 3     | Toi   | Resserre encore si l'agent sur-mock                                  |
| 4     | Duo   | Décision Git (`--no-ff` vs squash) avant de pousser sur du partagé   |
| 5     | Toi   | `/commit`                                                            |


### Scénario D — Documentation (doc en retard sur le code)


| Étape | Qui         | Action                                                         |
| ----- | ----------- | -------------------------------------------------------------- |
| 1     | Toi         | « J'ai beaucoup changé , revois la doc » + fichier(s)          |
| 2     | Agent       | Lit le code live ; liste les lacunes au-delà de la demande     |
| 3     | Duo         | Découpe par concept + README/index                             |
| 4     | Agent       | Externalise historique dans un fichier dédié si pertinent      |
| 5     | Toi → agent | `/commit`                                                      |
| 6     | Toi         | Vérifie qu'aucun fichier non demandé n'a été touché au passage |


