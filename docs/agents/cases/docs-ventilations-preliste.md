# Revue docs ventilations et prélistes


|                |                                                                 |
| -------------- | --------------------------------------------------------------- |
| Thème          | Docs                                                            |
| Arc            | restructuration documentation métier post-rework (I29/I32, AMQ) |
| Commits phares | `7a8c808` et commits docs associés                              |
| Période        | ~21 juillet 2026                                                |


## Contexte

Le fonctionnement ventilations / prélistes a beaucoup évolué depuis le rework ;`docs/ventilations.md` ne reflète plus le code.

L’agent revoit la doc à partir du code live, propose un split ventilations / prélistes, un README index.  
Puis externalisation de l’historique rework dans `PATCH_NOTES.md`  
Puis une session `/commit` révèle un dépassement de périmètre (edits non demandés) et un format de message à corriger.

## Dialogue

### Tour 1 — prompt

```text
@docs/ventilations.md 
J'ai bcp changer le fonctionnement depuis 
peux tu revoir ila documentaiton sur la creation des ventilations et des prelistes.
```

### Tour 1 — agent

- Lit la doc actuelle puis le code (ventilations, prélistes, pipeline AMQ).
- Prépare une mise à jour alignée sur l’implémentation réelle, pas l’ancien monolithe consumer.

### Tour 2 — prompt

```text
Qu'est ce que tu vois d'autre a documenter ?
Creer un README.md qui reference la documentations dans docs
Split ventilations en Ventilations d'un cote et prelistes de l'autre
```

### Tour 2 — agent

- Cartographie les lacunes (workflow AMQ, ADR préliste, glossaire CONTEXT).
- Propose le split `docs/ventilations.md` + `docs/prelistes.md` et un README racine comme hub.

### Tour 3 — prompt

```text
@.cursor/plans 
si tu veux voir ce qui s'est passe pour initialiser le readme
et aider a la documentation
```

### Tour 3 — agent

- Consulte les plans Cursor pour comprendre l’intention du README et les vagues de rework déjà documentées.
- Enrichit la proposition doc avec le fil historique (I29, split AMQ, bugfix rec054).

### Tour 4 — prompt

```text
@README.md (26-35) externalise dans un fichier PATCH_NOTES et link le ici

dans patch note Met en titre
# Patch Notes

## Version 3.0.0
,,,
```

### Tour 4 — agent

- Extrait la section « Historique du rework » du README vers `PATCH_NOTES.md` (titre + `## Version 3.0.0`).
- Remplace la section README par un lien vers le nouveau fichier.

### Tour 5 — prompt

```text
<available_subagent_types>
Available subagent_types and a quick description of what they do:
- generalPurpose: General-purpose agent for researching complex questions, searching for code, and executing multi-step tasks. Use when searching for a keyword or file and not confident you'll find the match quickly.
- explore: Fast agent specialized for exploring codebases. Use this when you need to quickly find files by patterns (eg. "src/components/**/*.tsx"), search code for keywords (eg. "API endpoints"), or answer questions about the codebase (eg. "how do API endpoints work?"). When calling this agent, specify the desired thoroughness level: "quick" for basic searches, "medium" for moderate exploration, or "very thorough" for comprehensive analysis across multiple locations and naming conventions.
- shell: Command execution specialist for running bash commands. Use this for git operations, command execution, and other terminal tasks.
- cursor-guide: Read Cursor product documentation to answer questions about how Cursor Desktop, IDE, CLI, Cloud Agents, Bugbot, and other features work. Use when the user asks 'In Cursor, how do I...?' or similar questions about Cursor products.
- ci-investigator: Investigate a single failing PR CI check and return a short root-cause summary. Use when the user asks to summarize, explain, diagnose, or investigate a specific failed check from a pull request.
- bugbot: Use only when the user *explicitly* asks for a Bugbot-like review of local code changes. When launching this subagent, set the Task description to exactly "Bugbot". Launch exactly one Bugbot subagent with `run_in_background: false` unless the user explicitly asks to run in background. Use this fixed prompt form: "Full Repository Path: ...\nDiff: <one of: \"branch changes\", \"uncom

[… tronqué — 29 lignes / 4535 car. d'origine]
```

### Tour 5 — agent

- Lance le workflow `/commit` : `git status`, diff, log pour préparer le message.
- **Ne doit pas** modifier les fichiers — seulement proposer le message.

### Tour 6 — prompt

```text
why did you change code when i just use the commit skill that ask you to generate a commit message and nothing else
```

### Tour 6 — agent

- Reconnaît le dépassement : le skill `/commit` autorise lecture du diff, pas correction de markdown « au passage ».
- Liste les edits non demandés (`docs/amq-workflow.md`, `CONTEXT.md`) et propose revert, laisser tel quel, ou inclure explicitement au message.

### Tour 7 — prompt

```text
isnt your commit message not properly formated in a code block ?
```

### Tour 7 — agent

- Corrige le format : **tout** le message (titre + why + bullets) dans **un seul** bloc code, copiable tel quel pour `git commit -m`.
- Représente le message docs complet (split ventilations/prélistes, `amq-workflow.md`, README, PATCH_NOTES, ADR 0001, glossaire CONTEXT).

## Ce que ça illustre

- **Doc = code live** : partir de « j’ai beaucoup changé » + `@fichier`, pas d’inventaire théorique.
- **Split par concept métier** : ventilations vs prélistes évite un pavé illisible pour les pairs.
- **Skill = périmètre strict** : `/commit` ne signifie pas « corriger le diff » ; 
- **Warning** = Rester en alerte et signaler immédiatement tout scope creep.

