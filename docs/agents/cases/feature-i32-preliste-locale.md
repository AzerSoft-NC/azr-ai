# Feature I32 — préliste locale / découplage S-REC-SAL


|                |                                                                                        |
| -------------- | -------------------------------------------------------------------------------------- |
| Thème          | Feature                                                                                |
| Arc            | `feature/541-I32` — préliste locale (`PrelisteFC` / `PrelisteBusiness`) vs proxy SAL   |
| Commits phares | `44ef8bf`, `ab025c4`, `f6b6226`, `3c1c67a`, `cd89534`, `91e00b4`, `1a27bdb` (et suite) |
| Période        | ~juin–juillet 2026                                                                     |


## Contexte

Ticket **541-I32** : absorber la préliste dans DEC (entity + bean métier + vue) et retirer la dépendance `S-REC-SAL-Contract`. 

Arc reconstruit depuis plusieurs fils du même chantier (plan rework phase 1) — sessions `65780407`, `00aa3f70`, `0c9a7249`, `816021a0`, `7e9d24dc`, `f7cb12e9`.  

Distinct des fiches **Schéma/SQL** préliste (boucle runner DB2) : ici le centre = **livraison métier** + découplage SAL ; le SQL n’est qu’enabler.

## Dialogue

### Tour 1 — prompt

```text
I'd like to reset all my branches and changes to this commit 347f0021b14a091364e94611a271e3320c3425cc

and redo everything with a more structured and clean plan
actual work contains a lot of back and forth

Disable tests

feature I32 :
- Integrate SAL 

refactor : 
- AMQConsumer
- Split classes following the single responsability principle
- Simplify utils
- Remove the overwhelming usage of conversions
- Streamline async workflow 

feature I29 :
Create decompte first

Simplify test with a lot more of pure mockito tests and a lot less of integration test ( No adaptation, just plain rewrite, (not the logic of the test but the set up part)

/grill-me 
```

### Tour 1 — agent

- Lit handoff / CONTEXT / état git (merge en cours, ~50 commits au-dessus de `347f002`).
- Ouvre le grill : baseline littéral vs garder le travail DI déjà vert.

### Tour 2 — prompt

```text
Redo everything like asked
The DI has been more or less reverted we don't use stateless anymore

Rename current local branch to backup/****
and reimplement everything > 
```

### Tour 2 — agent

- Backup branche courante → reset `347f002` → plan par phases.
- Pose I32 (absorption SAL / préliste locale) en **phase 1**.

### Tour 3 — prompt

```text
0 -> 5 is good
in phase 5 i'd like to go class by class 
and do a big squash of all tests commits at the end
a
```

### Tour 3 — agent

- Verrouille phases 0–5 ; phase 5 = Mockito class-by-class puis squash tests.
- Enchaîne les décisions grill (DI, I29, I32 full absorption, AMQ split, commits jalons).

### Tour 4 — prompt

```text
@image (1).png @image.png 

Fill @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/jpa/entities/PrelisteFC.java implementation with this 
```

### Tour 4 — agent

- Matérialise `PrelisteFC` depuis spéc / captures écran.
- Pose le modèle JPA local qui remplace les DTOs SAL.

### Tour 5 — prompt

```text
all columnDefinition must be nullable = false except update user

dont truncate anything
```

### Tour 5 — agent

- Ressserre les contraintes colonnes (NOT NULL sauf update user).
- Pas de troncature de champs — fidélité au schéma métier.

### Tour 6 — prompt

```text
Force-push feature/541-I32 to origin contradict the recent edits of the @context/plan-s-rec-dec-rework.md 
Also update Phase 1 progress checkbox in the @context/plan-s-rec-dec-rework.md 

then start A
```

### Tour 6 — agent

- Aligne remote + plan (checkbox phase 1) puis enchaîne l’implémentation phase 1.
- Fil exécution après le cadrage grill.

### Tour 7 — prompt

```text
/caveman ultra
lets go step by step
@S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/business/impl/PrelisteBusiness.java complete carboncopy for fix 1 
```

### Tour 7 — agent

- Complète `carbonCopy` (tous champs, sans id) ; `annuler` copie au lieu de muter l’original.
- Gate acceptation : tests préliste / OGI avancent après le fix métier.

### Tour 8 — prompt

```text
S-REC-DEC use to have a dependency to S-REC-SAL 

I've merge most it but still need to import S-REC-SAL-PService into S-REC-DEC-PService

What's left to do
```

### Tour 8 — agent

- Inventorie le reste de dépendance SAL (contract / PService / call-sites).
- Oriente vers suppression finale vs import résiduel.

### Tour 9 — prompt

```text
fix the prelisteBusiness wiring
```

### Tour 9 — agent

- Corrige le câblage CDI / injection de `prelisteBusiness` (tests / beans).
- Ferme la boucle intégration après l’absorption.

## Ce que ça illustre

- **Feature = ticket + livrable métier** : entity, bean, vue, rewiring — pas une chasse au stacktrace.
- **Grill puis exécution** : reset + phases avant le code ; force-push / checkbox plan = pivot « go ».
- **Acceptation via tests** : `carbonCopy` / wiring sont des gates du ticket, pas le sujet d’une fiche Debug.

