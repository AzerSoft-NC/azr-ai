# Étude de cas — workspace (racine environnement développeur)

**En date du :** 22 juillet 2026  
**Période observée :** 16 juin 2026 → 21 juillet 2026  
**Volume :** ~25 sessions agent (Cursor ouvert sur la racine workspace, hors dépôts projet individuels)

## Rôle du workspace

Environnement développeur partagé : scripts (`prj`, `srv`, …), Docker, serveurs locaux, Maven emballé, documentation d’usage. L’IA y joue le rôle de copilote **plateforme** — elle améliore le *terrain de jeu* sur lequel tournent les projets métier (`s-rec-`*, `e-rec-*`, etc.).

## Types d’usage dominants


| Type d’activité                    | Ordre de grandeur |
| ---------------------------------- | ----------------- |
| Infra / outillage workspace        | ~50 %             |
| Skills / mode opératoire           | ~15 %             |
| Hygiène Git / commits              | ~10 %             |
| Développement / exploration divers | ~15 %             |
| Questions courtes / exploration    | ~10 %             |


## Arcs de période

### Mi-juin → début juillet — Scripts et démarrage projet

Affinage de `prj start` / validation des dossiers projet, compréhension du poids des toolchains (Maven), premiers handoffs liés à l’accès distant. L’agent aide à rendre les commandes **fiables et documentées**.

### Mi-juillet — Serveurs locaux et onboarding

Travail sur la configuration **JBoss standalone** (alléger l’empreinte), `srv init` branché sur les versions pinnées (`dockers.conf`), et clarifications d’onboarding CLI. En parallèle, sujets d’accès (SSH, dépôts) qui bloquent le flux quotidien.

## Pratiques notables (généralisables)

- **Documenter l’environnement** (`docs/usage.md`, `docs/structure.md`) : l’agent s’appuie sur une vérité écrite plutôt que sur la mémoire orale.
- **Pins et reproductibilité** : versions de serveurs / images comme contrat, pas comme hasard de machine.
- **Alléger le runtime local** : moins de bruit = diagnostics métier plus rapides dans les dépôts applicatifs.
- **Handoffs d’infra** : même pattern que le métier — transmettre un blocage réseau / SSH de façon structurée.

## Ce que ça illustre pour une autre équipe

Sans plateforme locale soignée, l’IA métier passe son temps à combattre Docker, Maven et serveurs. 

Un workspace outillé transforme l’agent en **multiplicateur d’environnement** : les gains se répercutent sur tous les dépôts ouverts ensuite.

Recommandation de généralisation : traiter scripts + docs d’environnement comme un produit interne (même si le volume de sessions reste modeste), et séparer clairement cet espace des repos applicatifs.