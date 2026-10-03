# Playbooks — cas d’école S-REC-DEC

**Public :** pairs / développeurs  
**En date du :** 22 juillet 2026

Rundown de **vrais arcs** menés avec un agent Cursor sur `s-rec-dec-impl` (commits + transcripts).  
Objectif : montrer *comment* le travail se déroule — pas une version édulcorée.

## Règles du jeu (lire avant les fiches)


| Règle              | Détail                                                                               |
| ------------------ | ------------------------------------------------------------------------------------ |
| Prompts            | **Verbatim**, a l'exception des artefacts (logs, SQL longs) tronqués avec marqueur ; |
| Réponses **agent** | **Condensées** : Ce qui oriente le tour suivant, pas les pavés outils.               |
| Unité              | Un fichier = un **arc** (branche / fil de travail), pas un seul SHA.                 |
| Profondeur         | **Tours pivots jusqu’à fin d’arc** (diagnose → fix utilisable). Typiquement 4–8 ; **plus** si la solution continue (script générique, friction outil). Couper les tours sans pivot. |


Chaque fiche : contexte → dialogue → 3 takeaways.

---

## Debug

### [Consommateurs AMQ — Weld / TCCL](cases/debug-amq-weld-consumers.md)

Redelivery / crash sur thread AMQ. 

Note bugfix, imposes « ask before doing anything »
→ Explores MDB vs RA vs `@ApplicationScoped`  
→ Confrontes les hypothèses aux logs live et au legacy. 
→ Refus MDB (config vars) 
→ Solution by pattern legacy : `DecConsumerBootstrap` + `DecConsumer` `@Dependent` + processors `@LocalBean` (`e404eac`).




### [SQL0803 — identity après refresh prod → INT](cases/debug-sql0803-identity-refresh.md)

`saisir` casse en duplicate key après écrasement INT par la prod.  
   
Colles le stack → **hypothèses classées** → Confirmes le refresh (H1) → pointeur / `RESTART WITH` → effet domino → **script générique**.  
  
Correctif DB (`RESTART WITH`), pas de patch applicatif.

### [Pipeline AMQ — registry / processors](cases/debug-amq-pipeline-registry.md)

Rewrite déjà poussée → stacks EAP au redeploy (`TransactionRequiredException`, `JBAS011049` proxy stale).  
Logs d’abord → plan listener→consumer (« show me before ») → capitalisation CONTEXT.  
Distinct de Weld/TCCL (`rec054`) : même zone AMQ, autre arc.

---

## Refactor

### [SRP volet — plan + `/grill-me](cases/refactor-srp-volet.md)`

Reprise d’un gros plan de rework déjà branché.   
  
Grill question-par-question : 

- Stéréotypes DI
- Taille réelle de `VoletBusiness`
- Gate compile-only
- Jalons et règle « confirmation avant commit ».



### [ParametresVoletBO — dead code / taux](cases/refactor-parametres-volet-taux.md)

Suspicion « seul `tauxCotisation` sert ». 

Audit → plan → implémentation → message de commit → question sur un helper proxy encore superflu. 

Refactor piloté par usage réel, pas par intuition.

---

## Feature

### [I32 — préliste locale / découplage SAL](cases/feature-i32-preliste-locale.md)

Ticket 541-I32 : absorber préliste dans DEC (`PrelisteFC`, `PrelisteBusiness`, vue) et retirer `S-REC-SAL-Contract`.  

Grill + reset `347f002` → entity depuis spec → `carbonCopy` / wiring → fin de dépendance SAL.

### [I29 — ventilations débit / TRANCHE](cases/feature-i29-ventilations.md)

Ticket I29 en fils courts : 

- phase 3 vs 4 (schéma `TRANCHE` + éclatement régimes)
- split `DebitVoletBusiness` en générateur / annuleur avec `/grill-me`.

---

## Schéma / SQL

### [Create DEC_PRELISTE — SQL0104 et suite](cases/schema-sql-preliste-create.md)

Script create sur DB2 for i : 

- syntaxe, contraintes
- Droits vue
- Pièges `SQL0100` / mauvais schéma. 

Boucle erreur SQL → correction ciblée → rejeu.



### [UPDATE FK préliste — garde-fous](cases/schema-sql-fk-preliste-update.md)

Remap des FK volet vers `ID_PRELISTE_TOUS_TRIMESTRES`. 

Diagnostic `SQL0100`, `EXISTS`, limites du runner IBM i (`BEGIN…END`, CTE).

Migration prudente, pas un UPDATE aveugle.

---

## Test

### [Mockito — rewrite processor](cases/test-mockito-processor-rewrite.md)

Un test processor AMQ passé en Mockito pur : 

flux contexte/DB → métier → save → réponse non nulle.

Consignes ultra-ciblées ; l’agent resserre encore (« only test and mock context »).



### [Historique tests — squash vs `--no-ff](cases/test-mockito-history-squash.md)`

Après la migration Mockito : *Garder l’historique des réécritures ou squasher ?*

Décision Git (`--no-ff`, puis options de retour arrière) ancrée sur le plan de rework — pas seulement sur le code de test.

---

## Docs

### [Revue ventilations / prélistes](cases/docs-ventilations-preliste.md)

`docs/ventilations.md` en retard sur le code.   


Revue → split docs → index → `/commit` qui révèle un dépassement de périmètre et un format de message à corriger. 

La doc est un livrable piloté comme le code.



### [Doc agents — pitch → cas d’école](cases/docs-agents-cas-ecole.md)

Arc méta : snapshot hiérarchie sur DEC → handoff → playbooks pairs ici → grill des 12 cas (verbatim, `cases/`, ce README). Montre le même mode opératoire appliqué à la documentation elle-même.

---

## Index rapide


| Thème        | Fiches                                                                                                                |
| ------------ | --------------------------------------------------------------------------------------------------------------------- |
| Debug        | [AMQ Weld](cases/debug-amq-weld-consumers.md) · [SQL0803 identity](cases/debug-sql0803-identity-refresh.md) · [AMQ registry](cases/debug-amq-pipeline-registry.md) |
| Refactor     | [SRP volet](cases/refactor-srp-volet.md) · [ParametresVolet / taux](cases/refactor-parametres-volet-taux.md)          |
| Feature      | [I32 préliste](cases/feature-i32-preliste-locale.md) · [I29 ventilations](cases/feature-i29-ventilations.md)        |
| Schéma / SQL | [create préliste](cases/schema-sql-preliste-create.md) · [FK UPDATE](cases/schema-sql-fk-preliste-update.md)          |
| Test         | [Mockito processor](cases/test-mockito-processor-rewrite.md) · [squash history](cases/test-mockito-history-squash.md) |
| Docs         | [ventilations.md](cases/docs-ventilations-preliste.md) · [doc agents](cases/docs-agents-cas-ecole.md)                 |


