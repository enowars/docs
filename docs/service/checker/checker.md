# Checker Development

> This page is still under construction.

To learn how the checker fits into the overall repository structure, please review the [Getting Started Page](../../getting-started).

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

### Putflag/Getflag

### Putnoise/Getnoise

### Havoc

### Exploit

## Libraries

Your checker must be startable via
```bash
docker-compose up -f docker-compose.yml
```

It must conform the specifications.

You can write it any language you like, but we provide some guidance for the following: 

- [Python](checker-python.md)

There are also libraries for the following languages, but they are not covered extensively on this page, so they might be harder to get into. Also, the python library can be considered the reference implementation of the checker specification and thus will always match the current version of the API specification, which is not guaranteed for the below checker libraries.

- [Dotnet](checker-dotnet.md)
- [Golang](checker-golang.md)
- [Rust](checker-rust.md)

--8<-- "includes/abbreviations.md"


You can check whether you Checker is working with the [CLI](https://github.com/enowars/enochecker_cli).