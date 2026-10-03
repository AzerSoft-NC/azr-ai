# Refactor SRP volet — plan rec54 et `/grill-me`


|                |                                                              |
| -------------- | ------------------------------------------------------------ |
| Thème          | Refactor                                                     |
| Arc            | `refactor/rec54-SRP` — découpage `VoletBusiness` et phases   |
| Commits phares | — (planification / doc ; implémentation sur branches backup) |
| Période        | ~juillet 2026                                                |


## Contexte

Reprise d’un plan de rework S-REC-DEC déjà avancé sur branches backup. 

L’agent lance `/grill-me`, confronte plan vs baseline (stéréotypes DI, taille réelle de `VoletBusiness`, gate compile-only), puis affine le plan : checkboxes de suivi, jalons par phase, règle de confirmation avant commit, choix de modèle agent.

## Dialogue

### Tour 1 — prompt

```text
@/tmp/handoff-s-rec-dec-impl-2026-07-07.md @context/plan-s-rec-dec-rework.md 
Review plan see what could be enhanced
local branch exists @~/.cursor/projects/home-kako-workspace-projects-s-rec-dec-impl/terminals/18.txt:94-96 

/grill-me
```

### Tour 1 — agent

- Lit handoff, plan, `CONTEXT.md` et l’état de la branche locale.
- Prépare une session grill : tensions plan/code à valider avant d’implémenter.

### Tour 2 — prompt

```text
Context not up to date when deploy on standaloen jboss server injection fails update context
A is good
```

### Tour 2 — agent

- Retient la décision A : `@Business @Default` + injection champ pour le domaine, `@Stateless` pour l’infra AMQ.
- Doit mettre à jour `CONTEXT.md` : l’échec d’injection sur JBoss standalone est réel, pas obsolète.

### Tour 3 — prompt

```text
it was never part of the plan keep to the original plan -> 
Rewrite history to have a neat github tree.
The work has been done, the backup branches are the source of truth 
You can do A but don't overthink mindlessly the plan is overall already good
```

### Tour 3 — agent

- Liste 5 écarts plan/baseline (DI contradictoire, `VoletBusiness` ~1795 lignes vs ~368 cible, SAL/Phase 1, gate compile-only, couplages repository).
- Tu recentres : pas de rewrite d’historique maintenant, branches backup = vérité, plan globalement bon.

### Tour 4 — prompt

```text
which model do you recommand for phases is composer enough ?
```

### Tour 4 — agent

- Recommande un modèle « assez capable » pour les phases à risque deploy (pas seulement compile).
- Composer suffit pour doc/checklists ; phases CDI/deploy méritent un modèle plus patient ou validation humaine par tranche.

### Tour 5 — prompt

```text
Add a check box to follow what has to be done 
[ ] phase 1 
[ ] phase 2 etc....

And a Phase 1 - step 1
phase 1 - step 2 etc....

to follow what has to be done
```

### Tour 5 — agent

- Enrichit le plan avec barre de progression en tête + cases `[ ]` par phase et sous-étapes numérotées.
- Rend le suivi reprise/handoff lisible sans relire tout le chat.

### Tour 6 — prompt

```text
does this mean there will be n commit per phases (n being the number of substeps)
```

### Tour 6 — agent

- Non obligatoire : un commit par jalon de phase suffit souvent ; sous-étapes = checkpoints doc, pas n commits automatiques.
- Propose regrouper par phase mergeable sauf si une sous-étape casse le deploy.

### Tour 7 — prompt

```text
add a rule that ask confirmation before each commit
```

### Tour 7 — agent

- Ajoute une règle explicite dans le plan : pas de commit sans ton OK explicite à chaque jalon.

### Tour 8 — prompt

```text
to the plan not an overall rule
```

### Tour 8 — agent

- Limite la règle au document de plan rec54, pas à une rule Cursor globale — périmètre refactor seulement.

### Tour 9 — prompt

```text
i'm not sure i want to force push feature/* branches till all is done
is it mandatory what's the gain
```

### Tour 9 — agent

- Force-push non obligatoire : utile seulement si rewrite d’historique pour arbre linéaire.
- Alternative : merges normaux ou PRs depuis branches backup ; gain principal = lisibilité git, pas exigence technique.

## Ce que ça illustre

- `**/grill-me` avant gros refactor** : surface les contradictions plan/doc/code sans coder dans le vide.
- **Plan = instrument de suivi** : checkboxes + sous-étapes valent mieux qu’un monologue agent sur 1795 lignes.
- **Discipline de commit cadrée** : confirmation par jalon dans le plan, pas une règle globale ni un commit par micro-step.

