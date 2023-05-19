# Checker Development

To learn how the checker fits into the overall repository structure, please review the [Getting Started Page](../../getting-started). For more information on testing your checker and integrating it as part of the CI process, please review the [Testing Page](testing.md). You can find information on the [available libraries](#libraries) for implementing your checker at the end of the page.

## General Architecture and Core Concepts

While not directly relevant for the development of your service and corresponding checker, there are some parts of the general architecture of the CTF infrastructure  and core concepts that are useful to understand.

If you are interested in the low-level workings of the checker protocol, you should check out the [checker protocol specification](https://github.com/enowars/specification/blob/main/checker_protocol.md).

The `EnoEngine` is responsible for "deciding" which tasks to run and when to run them. This is done through the configuration of the engine itself. When the engine wants to launch a task, the `EnoLauncher` issues an HTTP request adhering to the checker protocol specification to the checker. This means that each checker is an HTTP service by itself.

When using one of the [libraries](#libraries), the library handles most or all of the functionality related to receiving and handling the HTTP requests. As a service author, you only implement the [checker methods](#checker-methods) and how they are called is transparent to you. You can assume that all validation of the request itself as well as authentication/authorization (should that ever be considered necessary) is handled by the library and does not need to be implemented as part of the checker methods.

However, while you can assume that the engine will only send reasonable requests, there are some cases where you might end up with an inconsistent state that you should handle in your implementation of the checker methods.

For example, the engine will send getflag-tasks even when the corresponding putflag-task is considered to have failed. The reasoning for this is that the flag might have been stored successfully and all relevant data for retrieving it was stored in the database, but only at a later point in the task did an error occur or the task timeouted after storing the flag and data in the database but before being able to return the success status. It would be unfair to consider all subsequent getflag-tasks to have failed. While it could be argued that from the perspective of the engine the putflag never succeeded and thus the flag can not be present in the service, it might in fact be there and the teams should get the chance to gain those SLA points by executing the getflag-task.

Since there is no way to distinguish between those cases from the perspective from the engine, the engine will also send getflag-tasks for putflag-tasks that have failed from the perspective of your checker (e.g. because the registration was unsuccessful) and thus the credentials are missing from the database. In those cases, your checker MUST NOT return an internal error and instead handle those cases gracefully, e.g. by returning MUMBLE with a response message indicating that the earlier user registration failed and thus the flag can not be retrieved.

### Task Chain

One important concept that you should fully understand is that of a "task chain" as well as which arguments of a `CheckerTaskMessage` can be considered unique identifiers for which purposes. A task chain is a series checker tasks that consist of one putflag-task with the corresponding getflag-tasks for the same flag, one putnoise-task with the corresponding getnoise-tasks for the same noise, a single havoc-task or or a single exploit-task.

In general, it can be said that you will probably want to use the `taskChainId` as unique identifier for storing e.g. usernames and passwords unless you have a very good reason to use something else. When your flag is stored in some location where it is visible to the logged in user, you probably register a new user in your putflag-task. When retrieving the flag in your getflag-task, you need to login as that user and check whether the flag is still present. In both of those tasks, the `taskChainId` will be identical, thus it makes sense to use the `taskChainId` as the identifier in your database for storing those credentials.

Some checker libraries, e.g. `enochecker3` for Python, provide abstraction layers around this mechanism in the form of e.g. a `ChainDB` object, which internally stores the data using the `taskChainId` as identifier and externally can be used like a normal key-value-store where all data stored/retrieved is always limited to the data related to the task chain of the current checker task being executed.

Other arguments in the `CheckerTaskMessage` like the `taskId`, `teamId`, `currentRoundId`, `relatedRoundId` and `variantId` are available to you and are used internally by the checker libraries for e.g. logging, but it is rare that you as the service developer have a good reason to actually use those values in the implementation of your checker tasks. Most importantly, unless you know what you are doing and have a good reason to do so, you do not want to use any of those values as identifiers for storing data in the checker's database.

One valid use case for using e.g. the `teamId` as a database id could be reusing accounts across multiple task chains to obfuscate the behavior of the checker a bit and ensure that not all requests sent by the checker look identical (e.g. all putflags start with the registration of a new user). However, such use cases require a lot of attention with error handling, for example, since a putflag-task should be independent from other tasks in the sense that an unrelated task failing must not lead to the putflag failing just because a user-account from the previous task is missing.

## Checker Methods

There are six methods defined in the checker protocol. Five of them, namely `putflag`, `getflag`, `putnoise`, `getnoise` and `havoc`, are used during the CTF and have a direct influence on the score, where as the `exploit` method is used only for (automated) testing and not used during the CTF.

For each of the different methods, there may be multiple variants. That means your checker might implement two different variants of `putflag` or `getflag` that store flags in different parts of the service. Ideally this should require the exploitation of different vulnerabilities, such that there are basically two different services within your service. In that case we speak of different "flag stores", which are also displayed on the scoreboard and are considered separately when identifying first bloods, meaning there is one first blood pre flag store and not just per service.

When looking at `putnoise`, `getnoise` and `havoc`, multiple variants simply allow you to test additional functionality of your service. All tasks for `putnoise`, `getnoise` and `havoc` must succeed for the service of a team to be considered "up" and the team receiving SLA points. 

### Putflag/Getflag

The `putflag` and `getflag` methods can be considered the core functionality of the checker. The `putflag` method is used to store a flag in the service, where as `getflag` is used to check if the flag is still present. Your checker must be able to handle multiple subsequent `getflag`-tasks for a single flag.

Since the flag must be placed somewhere in the service where it is not publicly accessible, you usually have some form of credentials (e.g. username and password) generated in your `putflag`-task that you need to store. Usually you would want to use the [`taskChainId`](#task-chain) as identifier in your database for storing and retrieving those credentials.

When implementing multiple variants for `putflag` and `getflag`, you must ensure that both methods have an equal number of variants. The corresponding `putflag` and `getflag` variants for the same flag store must have the same variant ids, i.e., the engine will call `getflag` with `variantId` 0 to check whether the flag deposited by the `putflag` task with `variantId` 0 ist still present.

Depending on the design of your service, it might be useful to have some publicly available information giving the players a hint where the current flag can be found. For example, this could be the username of the account which was used to store the flag and should thus be considered the target of the exploits. Such information can be returned as `attackInfo` in your `putflag`-method. This `attackInfo` is always a string, so if you only provide the username you can simply return that, if you want to return more complex JSON objects you need to stringify them before returning them. How you lay out the `attackInfo` (and if you provide `attackInfo` at all) is up to you as the service author to decide. In general, if, without `attackInfo`, the attackers would need to enumerate a large number of entries, causing high load to the service, it is a good idea to include `attackInfo`.

It can be assumed that, when enumerating all accounts/entries is theoretically possible, simply providing `attackInfo` reduces the load and makes the life easier for the attackers, the defenders and you as the organizer who needs to provide the network infrastructure. If finding the correct target to attack is part of your vulnerability/exploit somehow and providing `attackInfo` would take that away, you would probably not want to provide any information.

### Putnoise/Getnoise

The `putnoise` and `getnoise` methods are quite similar to `putflag` and `getflag`, so most things mentioned in the previous chapter apply here as well.

The key difference is that noise, unlike the flag, is not considered secret and thus might be stored in publicly available places. It just needs to be stored somewhere, where it can be retrieved later on. Unlike with flags, you can also use two different variants to store noise in the same location and place/retrieve it there using different methods (of course, whether this is possible or not depends on your service).

Since the noise is not intended to be exploited, the `putnoise` task does not have anything equivalent to `attackInfo`.

### Havoc

The `havoc` method can be used to test any functionality that is not covered by `putflag`/`getflag` or `putnoise`/`getnoise`. Unlike the other methods which are pairs of `put` and `get` and thus need to store information somewhere, each `havoc` is completely independent and thus you do not need to store any information in the service or checker.

You are of course free to reuse e.g. accounts from earlier `havoc`-tasks whose credentials you store in the checker database, however, the absence of such accounts MUST NOT lead to the `havoc` failing.

### Exploit

The `exploit` method is only used for testing purposes and will not be used during the CTF. By implementing this method, you are able to "prove" that your service can actually be exploited. This is especially useful as part of the CI process, to avoid accidentally "breaking" a vulnerability leading to an unexploitable service.

You can also implement multiple variants of the exploit method and also multiple variants for a single flag store. In some cases there are multiple vulnerabilities that allow retrieving a flag from the same flag store, in which case you should implement one exploit variant per vulnerability/exploit chain.

To actually "prove" that the exploit method is working, it needs to return a flag as the result of the task. Since there might be multiple flags that are exploitable with a single exploit, the caller provides a `flagHash` which is the hex-encoded SHA256-hash of the flag the caller wishes to retrieve. It is the caller's responsibility to place the flag there and provide the `attackInfo` if available.

When using `enochecker_test` for [testing](testing.md), `enochecker_test` first issues a `putflag` task with a newly generated flag. It then passes the `attackInfo` returned by the `putflag` and the hash of the flag as `flagHash` to the `exploit`-task. Most libraries include some convenience mechanism for dealing with the `flagHash`, e.g. the `FlagSearcher` in [`enochecker3`](https://github.com/enowars/enochecker3), which takes `str` or `bytes` as input and checks whether any of the plain text flags included in that input match the hash.

To allow the `exploit`-method to identify the flags matching the flag format in the data returned by the service, there is the argument `flagRegex`, which is a regular expression describing the format of the flag. This `flagRegex` is e.g. used internally by the `FlagSearcher` to identify the flags in the input passed to it.

For more details on how the `exploit`-method is used by the automated testing procedure with `enochecker_test`, please review the [testing chapter](testing.md).

Please note that some tools, most notably [`enochecker_cli`](https://github.com/enowars/enochecker_cli), provide convenience mechanisms for working with the `flagHash`. `enochecker_cli` expects the plain flag (passed in using `--flag`) as input and calculates the hash of the flag internally before issuing the request to the checker. This makes issuing subsequent `putflag`- and `exploit`-tasks during testing much easier, since you can simply leave the `--flag` from your `putflag`-call as is when changing the method to `exploit`.

## Libraries

You can write the checker in any language you like, but we provide some guidance for the following: 

- [Python](checker-python.md)

There are also libraries for the following languages, but they are not covered extensively on this page, so they might be harder to get into. Also, the python library can be considered the reference implementation of the checker specification and thus will always match the current version of the API specification, which is not guaranteed for the below checker libraries.

- [Dotnet](checker-dotnet.md)
- [Golang](checker-golang.md)
- [Rust](checker-rust.md)

You could write your checker in other languages by creating your own implementation of the [checker protocol specification](https://github.com/enowars/specification/blob/main/checker_protocol.md), but then you are responsible for ensuring the stability of the checker library in addition to your actual service and checker implementation.

--8<-- "includes/abbreviations.md"
