# Rewrite Mockito — `DebitVoletSocialProcessorTest`


|                |                                              |
| -------------- | -------------------------------------------- |
| Thème          | Test                                         |
| Arc            | Réécriture tests processors en Mockito pur   |
| Commits phares | branche `fix/rec54-tests` (suite ~173 tests) |
| Période        | ~juillet 2026                                |


## Contexte

Session ciblée sur un test processor AMQ : passer d’un setup lourd (Weld/Cucumber ou mocks multiples) à du **Mockito pur**. 

L’objectif n’est pas de valider le contenu de la réponse métier, mais le **flux** : lecture contexte/DB → logique métier → save → réponse non nulle.

## Dialogue

### Tour 1 — prompt

```text
@S-REC-DEC-MBusiness/src/test/java/nc/cafat/rec/dec/business/activemq/consumer/impl/DebitVoletSocialProcessorTest.java 

rewrite all full mockito 

just check that it retrieve data from context / db

call the business logic

set values and save then return a response ( don't check content of response just not null)
```

### Tour 1 — agent

- Lit le test existant et le processor pour comprendre le setup actuel.
- Prépare une réécriture centrée sur : mock des dépendances, stub contexte/DB, appel métier, assertion « réponse ≠ null ».

### Tour 2 — prompt

```text
there should be only test and mock context too
```

### Tour 2 — agent

- Affine le périmètre : **un seul mock** — `ProcessContext` — plus le strict minimum pour exécuter le processor.
- Recoupe avec les autres tests du module qui mockent déjà `ProcessContext` pour rester cohérent.

## Ce que ça illustre

- **Critère de fin explicite** : « not null, pas le contenu » évite un test qui fige trop la réponse métier.
- **Mock minimal** : « only test and mock context too » resserre le diff — pas de sur-mock des couches déjà couvertes ailleurs.
- **Arc test = flux, pas snapshot** : utile quand on migre une suite legacy vers Mockito pur sur un module CDI/EJB.

