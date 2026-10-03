# Consommateurs AMQ — crash Weld / TCCL (rec054)


|                |                                                            |
| -------------- | ---------------------------------------------------------- |
| Thème          | Debug                                                      |
| Arc            | `bugfix/rec054` — consommateurs Weld / TCCL                |
| Commits phares | `e404eac` (pipeline consumer) ; suite `b080756`, `6f3ec19` |
| Période        | ~juillet 2026                                              |


## Contexte

Messages AMQ en redelivery / crash sur thread `ActiveMQ Session Task-*` : `JBAS016071` (TCCL ≠ déploiement Weld) puis, après un premier fix, `JBAS011049` (proxy EJB stale au hot-redeploy).  
Point de départ : note `docs/bugfix/rec054-consumers-weld` + comparaison au pipeline legacy.  
**Livrable :** `DecConsumerBootstrap` + `DecConsumer` `@Dependent` + processors/`registry` réorganisés (`e404eac`).

## Dialogue

### Tour 1 — prompt

```text
@docs/bugfix/rec054-consumers-weld.mc
```

### Tour 1 — agent

- Lit la note bugfix ; enchaîne `/diagnose`.
- Recoupe code live vs doc / logs ; 
- **annonce** un ranking d’hypothèses falsifiables après les faits (pas encore la liste).

### Tour 2 — prompt

```text
ask before doing anything
```

### Tour 2 — agent

- Mode strict : pas de code / redeploy sans OK.
- Menu : confirmer H1 une fois classée, design CONTEXT, discuter MDB.
- Précise : le **ranking H1…Hn** arrive après les réponses aux « Information Still Needed » du bugfix.

### Tour 3 — prompt

```text
What about the message driven annotation ? what would it change ? Is it better ?
```

### Tour 3 — agent

- `@MessageDriven()` vide ≠ MDB configuré (container, TX, TCCL).
- État actuel = listener manuel + squelette MDB → pire des deux mondes.

### Tour 4 — prompt

```text
MDB ? RA ?

Is old pipeline not using this because not using the registry ?
```

### Tour 4 — agent

- MDB = livraison container ; RA = `activemq-rar` JCA sur EAP 6.
- Legacy avait déjà un registry, mais en EJB `@Singleton` — pas le même proxy Weld qu’un `@ApplicationScoped` touché depuis le thread AMQ.

### Tour 5 — prompt

```text
then @ApplicationScoped is an issue you injected ?
MDB could be a good enhancement too
```

### Tour 5 — agent

- Faits live : repro ~1 s de redelivery sur `srv-jboss-intra` ; CF JNDI, `beans.xml`, EAP 6.4 / Weld 1.1 ; live ≠ CONTEXT (`@MessageDriven()` vide + listener manuel).
- **Hypothèses classées :**
  1. **H1** TCCL worker AMQ ≠ déploiement Weld — touch proxy `DecProcessorRegistry` → `JBAS016071` — *si vrai* : saut EJB/MDB ou TCCL module avant `getProcessor` efface l’erreur
  2. **H2** `@MessageDriven()` vide = no-op delivery — *si vrai* : retirer l’annotation ne change rien au crash
  3. **H3** `@Inject DecConsumer` enregistre l’instance CDI comme listener (pas de proxy EJB / TCCL) — *si vrai* : `@EJB` + `@Stateless` pour `process` suffit même si subscribe reste manuel
  4. **H4** registry `@ApplicationScoped` = premier touch Weld qui casse — *si vrai* : tout autre proxy CDI depuis le thread AMQ échoue pareil
  5. **H5** `@TransactionAttribute` hors sujet pour *ce* crash — *si vrai* : après fix TCCL, risque suivant = TX / JPA
- Boucle feedback : logs `srv-jboss-intra` — pass = plus de `JBAS016071` sur ce message.
- MDB reste une option « clean », mais `@Configured` (selector Maven-filtered) ≠ `@ActivationConfigProperty` statique.

### Tour 6 — prompt

```text
when you implemented mdb you didnt use config vars so bad solution 
legacy classes here @context/amq-legacy-classes 

why not work same
```

### Tour 6 — agent

- Attempt 2 (`DecListener` + `@EJB DecConsumer`) : OK cold start, cassé hot-redeploy.
- Legacy marchait parce que le listener était `**@Dependent` (pas de proxy Weld)** ; le premier saut EJB posait le TCCL.
- Cible : recopier ce pattern, garder `@Configured`, garder le registry **derrière** un appel EJB.

### Tour 7 — prompt

```text
show me what does it look like
```

### Tour 7 — agent

- Esquisse concrète :

```
DecListener (@Startup @Singleton)
  └─ @Inject DecConsumer          ← CDI @Dependent

DecConsumer (@Default / @Dependent)
  ├─ connection + MessageListener + @Configured
  └─ premier proxy = EJB (TCCL) → registry / processors
```

### Tour 8 — prompt

```text
Wouldnt it be better to rename DecListenner then since it doesnt listen it handling the startup and teardown
```

### Tour 8 — agent

- Oui — le nom ment (legacy aussi).
- Propose `DecConsumerBootstrap` / `DecConsumerLifecycle` : start/stop only.

### Tour 9 — prompt

```text
bootstrap good
```

### Tour 9 — agent

- Verrouille les noms :

```
DecConsumerBootstrap  (@Startup @Singleton)
DecConsumer           (@Default / @Dependent)
DecMessageHandler     (@Stateless @LocalBean)  ← process + registry
```

- Attend le « go » pour réécrire.

### Tour 10 — prompt

```text
why can't we do like legacy just inject ?
because registry ?
```

### Tour 10 — agent

- Oui : registry `@ApplicationScoped` = proxy Weld sur le thread AMQ si on l’injecte dans le listener.
- Legacy évitait ce proxy sur le chemin `onMessage` ; le registry actuel force un saut EJB (ou équivalent) avant CDI.

### Tour 11 — prompt

```text
we could just inject all the processors 
@inject 
DebitVoletSocialProcessor ...;

and have a utility method
```

### Tour 11 — agent

- Possible mais moins extensible que le registry ; chaque processor reste un bean CDI/EJB avec le même problème de TCCL si appelé depuis le thread AMQ sans façade EJB.
- Pousse à garder registry **dans** le handler EJB, pas sur le `MessageListener`.

### Tour 12 — prompt

```text
lookupHandler ?
```

### Tour 12 — agent

- `lookupHandler` = JNDI **par message** (`java:module/DecMessageHandler`) pour éviter le `@EJB` de champ figé au deploy → `JBAS011049` au hot-redeploy.
- Ne remplace pas le besoin d’un appel EJB (TCCL + TX) ; remplace seulement le cache de vue.

### Tour 13 — prompt

```text
but old architecture didnt use that why
```

### Tour 13 — agent

- Legacy n’avait pas le combo « listener CDI + registry Weld `@ApplicationScoped` + hot-redeploy long » : moins de proxies CDI sur le worker AMQ.
- Le lookup JNDI est le prix du nouveau graphe de beans, pas une règle AMQ universelle.

## Solution livrée (`e404eac`)

**Symptôme root :** thread ActiveMQ ≠ TCCL du déploiement Weld → accès proxy CDI (`DecProcessorRegistry` / processors) → `JBAS016071`.  
**Symptôme secondaire :** `@EJB` injecté au `@PostConstruct` pendant un hot-redeploy → vue EJB stale → `JBAS011049`.

**Architecture figée (alignée commit + CONTEXT) :**

```
DecConsumerBootstrap (@Startup @Singleton)
        │  subscribe / unsubscribe
        ▼
DecConsumer (@Default, unscoped / @Dependent)
        │  MessageListener réel — instance directe, pas de client proxy Weld
        │  @Configured messageSelector conservé
        ▼
  (traitement métier + DecProcessorRegistry / processors)
        │
        ▼
Processors @Stateless @LocalBean  (vue no-interface, injection explicite)
```


| Pièce                         | Rôle                          | Pourquoi                                                                      |
| ----------------------------- | ----------------------------- | ----------------------------------------------------------------------------- |
| `DecConsumerBootstrap`        | start/stop queue only         | Sépare lifecycle EJB du listener AMQ (rename depuis `DecListener`)            |
| `DecConsumer` `@Dependent`    | `MessageListener` + connexion | ActiveMQ appelle une **instance directe** → pas de proxy Weld sur le worker   |
| `@Configured` sur le consumer | selector / disable            | MDB rejeté : activation config statique ≠ config CDI filtrée                  |
| Processors `@LocalBean`       | travail async                 | Expose la vue no-interface ; évite les trous d’injection CDI sur EAP 6.4      |
| Registry sous `process/`      | dispatch par type             | Garde l’extensibilité ; ne doit pas être le premier bean CDI touché sans TCCL |


**Hors MDB :** tu as explicitement refusé une solution MDB qui perdait les config vars — le fix reste listener manuel + pattern legacy modernisé.

**Suite du même arc (commits suivants, pas détaillés ici) :** résolution `DtoMessageType` par **nom** après FST (`b080756`) ; injection proxy MVT par champ (`6f3ec19`).

## Ce que ça illustre

- **Diagnose → design → noms → impl** : le fix n’est pas « patch Weld », c’est une **forme de beans** (Dependent listener + bootstrap + LocalBean).
- **Legacy comme oracle** : comparer au vieux pipeline explique *pourquoi* le registry casse aujourd’hui.
- **Cold start ≠ hot redeploy** : valider les deux ; le `lookupHandler` / JNDI apparaît seulement quand `JBAS011049` survit au premier fix TCCL.
- **Refuser le « clean » qui casse ton contrat** : MDB élégant mais incompatible `@Configured` → tu imposes le chemin viable.

