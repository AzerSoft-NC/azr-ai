# Migration FK préliste — UPDATE volet et garde-fous


|                |                                                                       |
| -------------- | --------------------------------------------------------------------- |
| Thème          | Schéma/SQL                                                            |
| Arc            | Script `02_alter_dec_volet_preliste_fk.sql` — remap FK → `PRELISTE_T` |
| Commits phares | — (itération guards / compatibilité runner IBM i)                     |
| Période        | ~juillet 2026                                                         |


## Contexte

Migration des FK `DEC_VOLET` (`FK_CES_PREL_KEY_FC`, `FK_CES_PREL_KEY_FC_ANNULEE`) de clés locales vers `ID_PRELISTE_TOUS_TRIMESTRES`, via jointure métier sur `DEC_PREL_KEY_FC` × `PRELISTE`.

La session tourne autour de `SQL0100` (UPDATE à 0 lignes), requêtes de diagnostic avec placeholders `${conf.scripts.*}`, garde-fous `EXISTS`, et limites du runner DB2 for i (`BEGIN…END`, procédures temporaires, CTE).

## Dialogue

### Tour 1 — prompt

```text
UPDATE ${conf.scripts.MRECDEC}.DEC_VOLET v
SET FK_CES_PREL_KEY_FC_ANNULEE = (
    SELECT p.ID_PRELISTE_TOUS_TRIMESTRES
    FROM ${conf.scripts.MRECDEC}.DEC_PREL_KEY_FC k
    INNER JOIN ${conf.scripts.PRELISTE} p
        ON p.NUMERO_COTISANT = k.NUMERO_COTISANT
       AND p.SUFFIXE_COTISANT = k.SUFFIXE_COTISANT
       AND p.PERIODE_ANNEE = k.PERIODE_ANNEE
       AND p.PERIODE_TRIMESTRE = k.PERIODE_TRIMESTRE
       AND p.PERIODE_MOIS_INTERIEUR_TRI = k.PERIODE_MOIS
       AND p.SEQUENCE = k.NUMERO_SEQUENCE
       AND p.NUMERO_ASSURE = k.NUMERO_ASSURE
       AND p.CODE_PROVENANCE_PRELISTES = k.PROVENANCE
       AND TRIM(p.NOM_PATRONYMIQUE_ASSURE) = TRIM(k.NOM_PATRONYMIQUE_ASSURE)
       AND TRIM(p.PRENOM_ASSURE) = TRIM(k.PRENOM_ASSURE)
    WHERE k.ID_CES_PREL_KEY_FC = v.FK_CES_PREL_KEY_FC_ANNULEE
    FETCH FIRST 1 ROW ONLY
)
WHERE v.FK_CES_PREL_KEY_FC_ANNULEE IS NOT NULL;

[… tronqué — 21 lignes / 933 car. d'origine]
```

### Tour 1 — agent

- Analyse le script et le schéma pour expliquer le `SQL0100` sur cet UPDATE annulée.

### Tour 2 — prompt

```text
all diagnostic returns no rows so why does it fail
```

### Tour 2 — agent

- Diagnostics vides + `SQL0100` = souvent **aucune ligne** avec `FK_CES_PREL_KEY_FC_ANNULEE IS NOT NULL` — pas un problème de jointure.
- Propose `COUNT(*)` sur la colonne annulée ; si 0, warning attendu, pas data cassée.

### Tour 3 — prompt

```text
give me a commands with variable to check invalid rows
```

### Tour 3 — agent

- Fournit requêtes avec les mêmes placeholders migration : volumes remap, lignes invalides (pas de match préliste) pour FK principale et annulée.

### Tour 4 — prompt

```text
SELECT COUNT(*) --.ID_CES_VOLET, v.FK_CES_PREL_KEY_FC
FROM ${conf.scripts.MRECDEC}.DEC_VOLET v
WHERE v.FK_CES_PREL_KEY_FC IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM ${conf.scripts.MRECDEC}.DEC_PREL_KEY_FC k
    INNER JOIN ${conf.scripts.PRELISTE} p
        ON p.NUMERO_COTISANT = k.NUMERO_COTISANT
       AND p.SUFFIXE_COTISANT = k.SUFFIXE_COTISANT
       AND p.PERIODE_ANNEE = k.PERIODE_ANNEE
       AND p.PERIODE_TRIMESTRE = k.PERIODE_TRIMESTRE
       AND p.PERIODE_MOIS_INTERIEUR_TRI = k.PERIODE_MOIS
       AND p.SEQUENCE = k.NUMERO_SEQUENCE
       AND p.NUMERO_ASSURE = k.NUMERO_ASSURE
       AND p.CODE_PROVENANCE_PRELISTES = k.PROVENANCE
       AND TRIM(p.NOM_PATRONYMIQUE_ASSURE) = TRIM(k.NOM_PATRONYMIQUE_ASSURE)
       AND TRIM(p.PRENOM_ASSURE) = TRIM(k.PRENOM_ASSURE)
    WHERE k.ID_CES_PREL_KEY_FC = v.FK_CES_PREL_KEY_FC
);

[… tronqué — 23 lignes / 870 car. d'origine]
```

### Tour 4 — agent

- ~490k lignes « sans match » peut inclure des FK **déjà remappées** (id préliste, plus de ligne `DEC_PREL_KEY_FC`).
- Propose 4 comptages : déjà remappé, orphelin key, key sans préliste, réellement remappable.

### Tour 5 — prompt

```text
rewrite step 2 with guards
```

### Tour 5 — agent

- Réécrit l’étape 2 avec garde `EXISTS` : ne met à jour que les lignes réellement remappable via jointure métier complète.

### Tour 6 — prompt

```text
i still get the SQL0100
```

### Tour 6 — agent

- Relit le script pour identifier quel statement lève encore `SQL0100` malgré les guards.

### Tour 7 — prompt

```text
OPTION B => SQL Error [42601]: [SQL0104] Elément syntaxique <FIN-INSTRUCTION> n'est pas correct. Eléments possibles : ;.
```

### Tour 7 — agent

- `SQL0104` sur bloc `BEGIN…END` anonyme : runner DBeaver / IBM i split sur `;` ou n’accepte pas le compound statement.
- Propose procédure temporaire `QTEMP` + `CALL` avec `IF EXISTS` avant UPDATE.

### Tour 8 — prompt

```text
cant use the WITH syntax then ?
```

### Tour 8 — agent

- `WITH` (CTE) est lisible et valide, mais **ne supprime pas** `SQL0100` si 0 lignes mises à jour.
- Seules voies : tolérer `SQLSTATE 02000` dans le runner, ou wrapper procédural — la syntaxe CTE ne change pas le comportement DB2.

## Ce que ça illustre

- **SQL0100 sur migration** : souvent « rien à faire » (colonne annulée vide), pas échec de la jointure métier.
- **Segmenter les comptages** : déjà remappé / orphelin / remappable avant un mass UPDATE.
- **Runner ≠ moteur SQL** : guards `EXISTS`, CTE et `IF` procédural n’ont pas la même acceptation sur DB2 for i — adapter au outil d’exécution.

