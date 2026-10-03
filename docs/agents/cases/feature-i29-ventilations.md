# Feature I29 — ventilations débit / schéma TRANCHE

| | |
| --- | --- |
| Thème | Feature |
| Arc | `feature/541-I29` — détail ventilations, services générer/annuler débit |
| Commits phares | `1a37b79`, `2ba3855`, `3e21763`, `dc29606` (et suite I29) |
| Période | ~juillet 2026 |

## Contexte

Arc métier I29 reconstruit depuis **plusieurs fils courts** du même chantier (plan `plan-s-rec-dec-rework.md`) : cadrage phase 3 vs 4 (schéma `DEC_VENTILATION` / `TRANCHE` + éclatement des régimes), alignement des noms de services débit sur le cycle de vie volet, puis découpe de `DebitVoletBusiness` en générateur / annuleur. Pas de prompts inventés — sessions `f0c197af`, `da911761`, `a6033c0f`.

## Dialogue

### Tour 1 — prompt

```text
@context/plan-s-rec-dec-rework.md 
continue phase 3
follow commit urles
```

### Tour 1 — agent

- Lit le plan, situe où la phase 3 s’est arrêtée.
- Prépare la suite Dozer / converters — tu recentres immédiatement sur le périmètre ticket.

### Tour 2 — prompt

```text
edits to @S-REC-DEC-PService/src/main/scripts/3.0.0/alter_dec_ventilation_type_cotisation.sql @S-REC-DEC-PService/src/main/scripts/3.0.0/rollback_dec_ventilation_type_cotisation.sql @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/jpa/entities/VentilationDebitVoletDB.java 

should be part of phase 4 since they are part of the I29 ticket

NB: la version 2.5.6 ne fonctionnera plus, suite aux maj de schéma, perte de rétrocompatibilité.

- Passage en version 3.0.0-SNAPSHOT (Cible 3.0.0)
- Upgrade des dépendances CTX 4.0 / DEC 3.0
- Ajouter une colonne TRANCHE de type Integer dans la table DEC_VENTILATION
- Stocker le script de maj SQL dans le repertoire projet
- Alimenter avec la valeur null sur toutes les lignes existantes
- Adapter l'implémentation afin de persister la totalité du détail des ventillations:
- la ligne regime MALADIE devient une ligne regime RUAMM et tranche 1 + une ligne regime RUAMM et tranche 2 (si cotisation tranche 2 sur le RUAMM)
- la ligne regime RETRAITE devient une ligne regime RETRAITE et tranche 1 + une ligne regime RETRAITE et tranche 2 (si cotisation tranche 2 sur la Retraite)
- la ligne regime AUTRES_REGIMES est éclaté en autant de ligne que nécéssaire
```

### Tour 2 — agent

- Sort le schéma / entité I29 de la phase 3 ; garde le cleanup Dozer dans le commit courant.
- Ancre le critère I29 : `TRANCHE` + éclatement des lignes de régime — phase 4 dédiée.

### Tour 3 — prompt

```text
@context/plan-s-rec-dec-rework.md 
Continue phase 3
Follow commit rules
```

### Tour 3 — agent

- Reprend le fil phase 3 sur un nouveau chat ; inspecte l’état repo.
- Arrive au moment où tu imposes la convention de nommage des services débit.

### Tour 4 — prompt

```text
pour etre coherente avec les service "Lifecycle" je propose que l'on appel AnnuleDebitVoletService et GenereDebitVoletService
```

### Tour 4 — agent

- Renomme pour coller au pattern `*VoletService` du lifecycle.
- Prépare le terrain pour une façade débit claire (générer vs annuler).

### Tour 5 — prompt

```text
<uploaded_documents>
The following documents have been saved to your filesystem. You can read them using your file-reading tool or other tools:
- ~/...
</uploaded_documents>


 @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/business/impl/DebitVoletBusiness.java 

Analyse class and split 
What is genererCotisationDebitee

what is annuler

what is shared
```

### Tour 5 — agent

- Cartographie la classe monolithe : génération, annulation, parties partagées.
- Pose les seams pour une découpe sans mélanger les responsabilités.

### Tour 6 — prompt

```text
create DebitVoletGenerator and DebitVoletCanceller 
Keep @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/business/impl/DebitVoletBusiness.java make it just an orchestrator  that inject  both classes and dispatch
/grill-me
```

### Tour 6 — agent

- Ouvre `/grill-me` sur le design orchestrateur + deux workers.
- Affûte les frontières avant de générer les classes.

### Tour 7 — prompt

```text
is there any overlap between @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/business/impl/DebitVoletGenerator.java and @S-REC-DEC-MBusiness/src/main/java/nc/cafat/rec/dec/business/impl/DebitVoletCanceller.java  ?
```

### Tour 7 — agent

- Compare les deux extractions ; signale le vrai partage vs la duplication acceptable.
- Boucle sur un split propre avant les commits I29 suivants (`ProcessContext`, persistance ventilations).

## Ce que ça illustre

- Un ticket feature long se découpe en **fils courts** : plan → schéma → naming → split — l’agent suit si tu recentres le périmètre.
- Les règles métier d’éclatement (régime / tranche) se donnent **en bullets dans le prompt**, pas en « fais I29 ».
- `/grill-me` arrive **après** l’analyse, au moment du design de classes — pas avant d’avoir lu le monolithe.
