# Étude de cas — `s-rec-dec-impl`

**En date du :** 22 juillet 2026  
**Période observée :** 17 juin 2026 → 22 juillet 2026  
**Volume :** ~180 sessions agent (workspace ouvert sur ce dépôt uniquement)

## Rôle du workspace

Dépôt d’implémentation **DEC** (décomptes / cotisations employeur) dans l’écosystème Merlin / JBoss. 

C’est le cas d’usage principal de l’IA agentique sur du **logiciel métier legacy** : domaine riche, runtime exigeant, évolutions fonctionnelles et corrections imbriquées.

## Types d’usage dominants

Répartition approximative des sessions (classification thématique des échanges, arrondie) :


| Type d’activité                       | Ordre de grandeur |
| ------------------------------------- | ----------------- |
| Développement / exploration divers    | ~25 %             |
| Conception / domaine métier           | ~18 %             |
| Documentation / handoffs              | ~14 %             |
| Hygiène Git / commits                 | ~13 %             |
| Diagnostic / debug runtime            | ~12 %             |
| Skills / mode opératoire              | ~7 %              |
| Schéma / SQL                          | ~3 %              |
| Autres (outillage, questions courtes) | ~8 %              |




Lecture utile pour une autre équipe : l’agent n’est pas cantonné au « génération de code ».

Une part importante du temps sert à **stabiliser le runtime**, **clarifier le domaine** et **laisser une trace écrite**.

## Arcs de période

### Mi-juin → début juillet — Pipeline messagerie et déploiement

Focus sur la refonte / stabilisation du chemin **ActiveMQ**, l’intégration **Weld / CDI** côté consommateurs, et les échecs de déploiement JBoss. 

L’agent sert surtout de copilote de diagnostic : lire les symptômes runtime, proposer des hypothèses, itérer sur le code et la config.

### Début → mi-juillet — Domaine cotisations et persistance

Travail sur les concepts métier **ventilations**, **préliste**, annulation / validation de volets, et ajustements de **schéma / contraintes**. L’agent appuie la cohérence entre code, scripts et documentation de domaine (`CONTEXT`, docs techniques, ADR).

### Mi-juillet → fin de période — Qualité de livraison

Montée des rituels **commits thématiques**, revue de docs (ex. ventilations), handoffs entre sessions, et nettoyage d’historique Git ponctuel. 

L’IA devient un accélérateur de **discipline de livraison**, pas seulement de production de diff.

## Pratiques notables (généralisables)

- **Glossaire de domaine vivant** (`CONTEXT.md`) : réduit les ambiguïtés (ventilation, préliste, annulation…) avant de coder.
- **Docs ciblées** (workflow AMQ, ventilations, bugfix) : l’agent lit et met à jour la mémoire d’équipe, pas seulement le code.
- **Handoffs** : passages de contexte structurés entre sessions / machines / collègues.
- **Skills transverses** (`/commit`, modes de communication, grill de conception) : les rituels répétables sortent du prompt improvisé.
- **Boucle diagnostic** : symptôme runtime → hypothèse → changement minimal → re-test, plutôt qu’une réécriture large.

## Ce que ça illustre pour une autre équipe

Sur un SI métier legacy, l’IA agentique apporte le plus quand :

1. le **langage métier** est explicite (sinon l’agent invente) ;
2. les **échecs runtime** sont traités comme un flux de travail normal, pas comme une exception ;
3. la **documentation** est un livrable à part entière (sinon chaque session repart de zéro) ;
4. les **commits** restent humains dans l’intention, assistés dans l’exécution.

Ce workspace montre une adoption **intensive et ancrée produit**, pas une expérimentation hors sol.