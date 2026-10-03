# Schéma DEC_PRELISTE — script create et SQL0104


|                |                                                                           |
| -------------- | ------------------------------------------------------------------------- |
| Thème          | Schéma/SQL                                                                |
| Arc            | Scripts `3.0.0` — `01_create_dec_preliste_schema.sql`, prérequis FK volet |
| Commits phares | — (itération scripts migration IBM i)                                     |
| Période        | ~juillet 2026                                                             |


## Contexte

Création du schéma/vues `DEC_PRELISTE` sur DB2 for i (IBM i). 

La session enchaîne erreurs de syntaxe (`SQL0104`), nommage de contraintes (`SQL0204`), droits sur vue (`SQL0551`), puis interprétation des `SQL0100` sur des UPDATE de migration — avec un piège classique : comptages contradictoires quand le remap a déjà été joué ou le mauvais schéma est ciblé.

## Dialogue

### Tour 1 — prompt

```text
SQL Error [42601]: [SQL0104] Elément syntaxique ; n'est pas correct. Eléments possibles : <FIN-INSTRUCTION>.@S-REC-DEC-PService/src/main/scripts/3.0.0/01_create_dec_preliste_schema.sql
```

### Tour 1 — agent

- Inspecte le script create pour la syntaxe IBM i / DB2 autour du point-virgule ou d’une instruction mal fermée.

### Tour 2 — prompt

```text
missing the scehma as prefix to view name ?
```

### Tour 2 — agent

- `SET SCHEMA` devrait suffire, mais un préfixe explicite est plus sûr et aligné avec le script `02`.
- Propose d’ajouter le préfixe schéma sur la vue.

### Tour 3 — prompt

```text
com.ibm.as400.access.AS400JDBCSQLSyntaxErrorException: [SQL0204] Q_MRECDECINT_CES_VOLET_FK_CE00011_00001 de type *N dans MRECDECINT non trouvé.
	at com.ibm.as400.access.JDError.createSQLExceptionSubClass(JDError.java:941)
	at com.ibm.as400.access.JDError.throwSQLException(JDError.java:738)
	at com.ibm.as400.access.AS400JDBCStatement.commonPrepare(AS400JDBCStatement.java:1634)
	at com.ibm.as400.access.AS400JDBCStatement.execute(AS400JDBCStatement.java:2148)
	at org.jkiss.dbeaver.model.impl.jdbc.exec.JDBCStatementImpl.execute(JDBCStatementImpl.java:333)
	at org.jkiss.dbeaver.model.impl.jdbc.exec.JDBCStatementImpl.executeStatement(JDBCStatementImpl.java:134)
	at org.jkiss.dbeaver.ui.editors.sql.execute.SQLQueryJob.executeStatement(SQLQueryJob.java:716)
	at org.jkiss.dbeaver.ui.editors.sql.execute.SQLQueryJob.lambda$executeSingleElement$1(SQLQueryJob.java:600)
	at org.jkiss.dbeaver.model.exec.DBExecUtils.tryExecuteRecover(DBExecUtils.java:210)
	at org.jkiss.dbeaver.ui.editors.sql.execute.SQLQueryJob.executeSingleElement(SQLQueryJob.java:619)
	at org.jkiss.dbeaver.ui.editors.sql.execute.SQLQueryJob.executeSingleQuery(SQLQueryJob.java:480)
	at org.jkiss.dbeaver.ui.editors.sql.execute.SQLQueryJob.run(SQLQueryJob.java:255)
	at org.jkiss.dbeaver.model.runtime.AbstractJob.run(AbstractJob.java:110)
	at org.eclipse.core.internal.jobs.Worker.run(Worker.java:63)
```

### Tour 3 — agent

- `SQL0204` : la contrainte FK nommée n’existe pas encore dans `MRECDECINT`.
- Recoupe script `02` et l’ordre d’exécution (create vs alter FK).

### Tour 4 — prompt

```text
err when doing this UPDATE MRECDECINT.DEC_VOLET v
SET FK_CES_PREL_KEY_FC = NULL
WHERE v.FK_CES_PREL_KEY_FC IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM MRECDECINT.DEC_PRELISTE p
    WHERE p.ID_PRELISTE_TOUS_TRIMESTRES = v.FK_CES_PREL_KEY_FC
);
```

### Tour 4 — agent

- Analyse les causes probables sur IBM i (vue vs table, droits, jointure) et propose une réécriture plus sûre.

### Tour 5 — prompt

```text
SELECT COUNT(*) FROM MRECDECINT.DEC_PRELISTE

==> SQL Error [42501]: [SQL0551] Non autorisé à l'objet DEC_P00001 dans MRECDECINT, de type *FILE.
```

### Tour 5 — agent

- La vue existe (`DEC_P00001` = nom court IBM i) mais l’utilisateur SQL n’a pas les droits.
- Vérifie si d’autres scripts accordent `GRANT` après création des vues.

### Tour 6 — prompt

```text
[SQL0100] La ligne n'a pas été trouvée pour UPDATE.
[SQL0100] La ligne n'a pas été trouvée pour UPDATE.
[SQL0100] La ligne n'a pas été trouvée pour UPDATE.
[SQL0100] La ligne n'a pas été trouvée pour UPDATE.
@S-REC-DEC-PService/src/main/scripts/3.0.0/02_alter_dec_volet_preliste_fk.sql:18-78
```

### Tour 6 — agent

- `**SQL0100` n’est pas un échec** : 0 lignes mises à jour par statement (souvent warning DBeaver).
- Tableau par étape (remap FK, remap annulée, clear orphans) ; safe de continuer vers `ADD CONSTRAINT` si les anciennes FK sont déjà droppées.
- Donne une requête de contrôle rapide sur `DEC_VOLET`.

### Tour 7 — prompt

```text
TOTAL |FK_NON_NULL|FK_ANN_NON_NULL|
------+-----------+---------------+
491706|     489997|              0|
```

### Tour 7 — agent

- Contradiction : ~490k FK non null vs quatre `SQL0100` → les UPDATE n’ont probablement **pas** touché le même `MRECDECINT.DEC_VOLET` (schéma, placeholder `${conf.scripts.MRECDEC}` non substitué, ou statements non exécutés).
- Propose deux comptages : clés locales `DEC_PREL_KEY_FC` vs ids déjà remappés `BDEV.PRELISTE_T`.
- **Alerte** : re-jouer le remap si déjà fait peut NULLer ~490k FK.

## Ce que ça illustre

- **Ordre scripts IBM i** : create schéma/vues → droits → remap → contraintes ; `SQL0204` signale souvent un enchaînement inversé.
- **SQL0100 ≠ erreur data** : interpréter comme « rien à mettre à jour », pas comme échec de jointure.
- **Diagnostiquer avant mass UPDATE** : distinguer clé locale vs id préliste déjà en place évite une migration destructive.

