# Doc agents — pitch hiérarchie → playbooks cas d’école


|                |                                                                           |
| -------------- | ------------------------------------------------------------------------- |
| Thème          | Docs                                                                      |
| Arc            | création doc agents : snapshot DEC → handoff → reorg pairs → grill 12 cas |
| Commits phares | — (documentation workspace ; pas de commit métier DEC)                    |
| Période        | 22 juillet 2026                                                           |


## Contexte

Arc **méta** en deux temps.

**Session DEC** (`1fc54f50`) : demande de synthèse multi-workspaces pour la hiérarchie, grill sur le cadrage (snapshot vs journal), implémentation du pitch. 

**Continuation workspace** (`f44a3b98`) : handoff reçu, version pairs plus hands-on, séparation `pitch/` / `playbooks/`, renommage en `playbook-rc1.md`, puis grill `/grill-me` pour inventer 12 cas d’école S-REC-DEC ancrés sur de vrais transcripts — règles verbatim, réponses condensées, cas méta incluant cette doc.

## Dialogue

### Partie 1 — session DEC (pitch / snapshot)

#### Tour 1 — prompt

```text
want to create a rundown of i work on different workspaces 
-> ~/...
-> ~/...
-> ~/...

Can you create a comprehensive documentation by workspace in ~/...
-> one .md file by workspace
-> One README.md that show stats and a global IDEA of how i use AI

/grill-me
```

#### Tour 1 — agent

- Explore les logs / transcripts par workspace.
- Ouvre le grill : première question sur le **public** et la **forme** (snapshot exécutif vs journal de sessions).

#### Tour 2 — prompt

```text
A - goal is to create a rundown of how i work and present to higherups and generalize to corp not log every ounce of work
```

#### Tour 2 — agent

- Verrouille **A** : snapshot pour higher-ups, généralisable corp — pas timesheet chat-par-chat.
- Propose le cadrage **hybride C** : README = modèle réutilisable ; fichiers workspace = preuves nommées.

#### Tour 3 — prompt (handoff from other workspace)

```text
Documentation agents (snapshot hiérarchie)

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created.
Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.
```

#### Tour 3 — agent

- Agrège stats transcripts, rédige `docs/agents/` (README + 3 études de cas workspace).
- Ton orienté direction : patterns, outcomes, arcs légers — confidentialité B.

---

### Partie 2 — continuation workspace (pairs / playbooks)

#### Tour 4 — prompt

```text
@/tmp/handoff-docs-agents-snapshot-2026-07-22.md 

/caveman ultra

documentation is good for higher ups.

But i'd like a more hands on verison to show my peers.

Something with a more detail step by step process.

With examples/use cases
```

#### Tour 4 — agent

- Lit le handoff et la doc pitch existante.
- Esquisse un playbook pairs : recettes, prompts type, scénarios bout-en-bout (diagnostic, domaine, commit, handoff).

#### Tour 5 — prompt

```text
keep current doc as is. just move it to a pitch/ subfolder

and create new doc ( playbooks and all in another subfolder)
```

#### Tour 5 — agent

- Planifie puis exécute la reorg : `docs/agents/pitch/` (synthèse inchangée) + `docs/agents/playbooks/` (mode d’emploi pairs).
- README racine = index fin ; déplace les fichiers, restaure le pitch sans le lien peer ajouté en session précédente.

#### Tour 6 — prompt

```text
j'ai renomme ton playbook/README en @docs/agents/playbooks/playbook-rc1.md 

c'est sympa comme idee et je vais le retravailler tt seul mais je voudrais que tu fasses un README qui est un veritable RUNDOWN de qq cas d'ecole que j'ai vraiment fait parmis mes commis sur S-REC-DEC 

avec un fichier par cas qui fait un run down avec des exemple de prompt

et dans le readme tu pointes vers ces exemples

avec au moins 2 exemple par thematique Refactor / debug / ....

/grill-me 
```

#### Tour 6 — agent

- Grill relancé : explore commits DEC + ~209 transcripts pour ancrer les cas.
- **Q1** : propose Debug / Refactor / Feature / Schéma-SQL ; en attente de validation Test + Docs.

#### Tour 7 — prompt

```text
oui ajoutes test et docs la decoupe est top sinon
```

#### Tour 7 — agent

- Valide **6 thèmes × 2 cas = 12 fiches** ; unité = **arc** ; template 4–8 tours ; `cases/` + `playbook-rc1.md` à part.
- Règles figées : prompts **verbatim** (artefacts tronqués), réponses agent **condensées**.

#### Tour 8 — prompt

```text
cases/docs-ventilations-preliste.md
cases/docs-coeur-metier-apres-refactor.md 
semble similaire/lie 

enleve un des deux et ajoutes en dernier la creation de cette documentation (session precedente dans workspace s-rec-dec-impl - le handoff - la continuation dans cette session)
```

#### Tour 8 — agent

- Retire `docs-coeur-metier-apres-refactor.md` ; ajoute `**docs-agents-cas-ecole.md**` (arc DEC pitch → handoff → cette session).
- Plan d’implémentation prêt : README rundown + 12 fiches.

#### Tour 9 — prompt

```text
go
```

#### Tour 9 — agent

- Plan d’implémentation figé : README rundown + 12 fiches sous `playbooks/cases/`.
- Lance l’écriture des cas depuis les transcripts JSON (verbatim user, agent condensé).

## Ce que ça illustre

- **Deux publics, deux dossiers** : `pitch/` pour la direction, `playbooks/` pour les pairs — pas un seul doc hybride.
- **Grill avant volume** : 12 cas × template × règles verbatim se décident question par question, pas en rédigeant d’abord.
- **Cas méta utile** : documenter *comment* on a produit la doc agents évite la mise en abîme tout en gardant les autres fiches autonomes.
- **Handoff = fil continu** : le snapshot DEC et la continuation workspace forment un arc livrable, pas deux silos.

