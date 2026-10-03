# Pipeline AMQ — registry et processors (rewrite)


|                |                                                                               |
| -------------- | ----------------------------------------------------------------------------- |
| Thème          | Debug                                                                         |
| Arc            | Rewrite pipeline AMQ — `DecProcessorRegistry`, processors, listener lifecycle |
| Commits phares | — (itération runtime + doc CONTEXT)                                           |
| Période        | ~juillet 2026                                                                 |


## Contexte

Réécriture complète du pipeline ActiveMQ DEC : nouveaux processors, registry CDI, tests à transposer. 

La session enchaîne erreurs runtime EAP 6.4 (transaction JTA, proxy EJB stale au redeploy), stabilisation du pattern listener → consumer, puis capitalisation dans CONTEXT (annotation `@Business`, architecture legacy).

Distinct de [`debug-amq-weld-consumers.md`](debug-amq-weld-consumers.md) (`bugfix/rec054` / TCCL) : ici le fil part d’une rewrite déjà poussée et enchaîne sur les stacks live.

## Dialogue

### Tour 1 — prompt

```text
i completly rewrote AMQ pipeline @~/... 

Keep the test just transpose as necessary
```

### Tour 1 — agent

- Inspecte le nouveau pipeline et les tests existants.
- Transpose les assertions aux nouveaux types sans réécrire la couverture fonctionnelle.

### Tour 2 — prompt

```text
20:09:18,908 ERROR [org.apache.activemq.ActiveMQMessageConsumer] (ActiveMQ Session Task-3) ID:NMI17779-42845-1783627504837-1:1:1:1 Exception while processing message: ID:NMI17779-34769-1783626923340-7:1:1:1:1: javax.persistence.TransactionRequiredException: JBAS011469: Transaction is required to perform this operation (either use a transaction or extended persistence context)
        at org.jboss.as.jpa.container.AbstractEntityManager.transactionIsRequired(AbstractEntityManager.java:692) [jboss-as-jpa-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at org.jboss.as.jpa.container.AbstractEntityManager.merge(AbstractEntityManager.java:547) [jboss-as-jpa-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at nc.cafat.rec.dec.business.activemq.process.processors.MouvementPersonnelProcessor.process(MouvementPersonnelProcessor.java:78) [S-REC-DEC-MBusiness@3.0-SNAPSHOT.jar:]
        at nc.cafat.rec.dec.business.activemq.process.processors.MouvementPersonnelProcessor$Proxy$_$$_WeldSubclass.process(MouvementPersonnelProcessor$Proxy$_$$_WeldSubclass.java) [S-REC-DEC-MBusiness@3.0-SNAPSHOT.jar:]
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) [rt.jar:1.8.0_492]
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) [rt.jar:1.8.0_492]
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) [rt.jar:1.8.0_492]
        at java.lang.reflect.Method.invoke(Method.java:498) [rt.jar:1.8.0_492]
        at org.jboss.weld.interceptor.proxy.SimpleInterceptionChain.invokeNextInterceptor(SimpleInterceptionChain.java:85) [weld-core-1.1.34.Final-redhat-1.jar:1.1.34.Final-redhat-1]
        at org.jboss.weld.interceptor.proxy.InterceptorInvocationContext.proceed(InterceptorInvocationContex

[… tronqué — 98 lignes / 13686 car. d'origine]
```

### Tour 2 — agent

- Diagnostique `TransactionRequiredException` sur `merge` : le thread listener AMQ n’ouvre pas de transaction JTA.
- Compare `DecConsumer` / processors avec l’ancien setup fonctionnel pour rétablir `@TransactionAttribute(REQUIRED)`.

### Tour 3 — prompt

```text
20:14:29,401 ERROR [org.apache.activemq.ActiveMQMessageConsumer] (ActiveMQ Session Task-5) ID:NMI17779-42845-1783627504837-1:1:1:1 Exception while processing message: ID:NMI17779-34769-1783626923340-7:1:1:1:1: java.lang.IllegalStateException: JBAS011049: Component is stopped
        at org.jboss.as.ee.component.BasicComponent.waitForComponentStart(BasicComponent.java:112) [jboss-as-ee-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at org.jboss.as.ee.component.ViewService$View.invoke(ViewService.java:184) [jboss-as-ee-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at org.jboss.as.ee.component.ViewDescription$1.processInvocation(ViewDescription.java:185) [jboss-as-ee-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at org.jboss.invocation.InterceptorContext.proceed(InterceptorContext.java:288) [jboss-invocation-1.1.3.Final-redhat-1.jar:1.1.3.Final-redhat-1]
        at org.jboss.invocation.ChainedInterceptor.processInvocation(ChainedInterceptor.java:61) [jboss-invocation-1.1.3.Final-redhat-1.jar:1.1.3.Final-redhat-1]
        at org.jboss.as.ee.component.ProxyInvocationHandler.invoke(ProxyInvocationHandler.java:73) [jboss-as-ee-7.5.17.Final-redhat-4.jar:7.5.17.Final-redhat-4]
        at nc.cafat.rec.dec.business.activemq.process.DecProcessorRegistry$$$view74.getProcessor(Unknown Source) [S-REC-DEC-MBusiness@3.0-SNAPSHOT.jar:]
        at sun.reflect.GeneratedMethodAccessor74.invoke(Unknown Source) [:1.8.0_492]
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) [rt.jar:1.8.0_492]
        at java.lang.reflect.Method.invoke(Method.java:498) [rt.jar:1.8.0_492]
        at org.jboss.weld.util.reflection.SecureReflections$13.work(SecureReflections.java:267) [weld-core-1.1.34.Final-redhat-1.jar:1.1.34.Final-re

[… tronqué — 29 lignes / 4033 car. d'origine]
```

### Tour 3 — agent

- Qualifie `Component is stopped` sur `DecProcessorRegistry` : listener AMQ encore accroché à un proxy EJB arrêté après redeploy.
- Passe le registry en bean CDI et durcit le lifecycle listener (fermeture propre de la connexion).

### Tour 4 — prompt

```text
can you make a list of all your recent changes per class (excluding tests)
```

### Tour 4 — agent

- Inventorie les changements AMQ hors tests, classe par classe — base pour valider l’état avant la suite.

### Tour 5 — prompt

```text
i retstarted everything but still have component is stoplped error
```

### Tour 5 — agent

- Même après restart complet, le listener peut conserver un proxy EJB mort.
- Propose le split : singleton propriétaire du listener, délégation vers `DecConsumer` pour la transaction.

### Tour 6 — prompt

```text
show me changes before doing it
```

### Tour 6 — agent

- Plan non appliqué : `DecListener` (`@Singleton`) implémente `MessageListener`, `setMessageListener(this)`, `onMessage` → `@EJB DecConsumer`.
- Évite de piner un proxy SLSB sur la connexion AMQ ; registry `@ApplicationScoped` et processors inchangés.
- Attend ton « go » avant patch.

### Tour 7 — prompt

```text
why not @DecProducer.java (33-35)  on DecConsumer too
```

### Tour 7 — agent

- Compare ce que génère `@Business` (Merlin) vs `@Stateless` actuel sur `DecConsumer`.
- Éclaire si l’annotation unifie le pattern producer/consumer.

### Tour 8 — prompt

```text
add to context how it use to work since you analysed that too add that to a file in context/ and link it in CONTEXT.md
```

### Tour 8 — agent

- Documente l’ancien pipeline AMQ dans `context/` et lie depuis `CONTEXT.md`.
- Capitalise l’analyse `@Business` et le fonctionnement legacy pour les sessions suivantes.

## Ce que ça illustre

- **Logs avant refactor aveugle** : `TransactionRequiredException` puis `JBAS011049` imposent de séparer problème TX et problème lifecycle/proxy.
- **« show me before doing it »** : sur EAP 6.4 / Weld, un plan listener→consumer vaut mieux qu’un patch itératif au redeploy.
- **Doc CONTEXT comme sortie** : après une rewrite, figer legacy + annotations métier évite de re-diagnostiquer la même stack.
