# Inner Workings

In order to store flags to capture and check whether a teams service is still running nominally the Engine dispatches several requests in each round.

## Request Types

| Request    | Purpose                                     |
| :--------- | :------------------------------------------ |
| `putflag`  | Inserts the flag into the service           |
| `getflag`  | Retrieves the flag from the service         |
| `havoc`    | Checks the service functionality            |
| `putnoise` | Insert other (public) data into the service |
| `getnoise` | Check other (public) data                   |

## Basic requests

```mermaid
sequenceDiagram
    Gameserver->>+Checker: putflag
    Checker->>+Service: store flag
    Gameserver->>+Checker: getflag
    Checker->>+Service: retrieve flag
    Service->>+Checker: retrieve flag

```

## Timing

One round generally lasts 60 seconds. It is divided into 4 quarters, which each last 15 seconds.
The checker tasks are called in the depicted way:

> TODO: Are those scheduled right (the slides differ)?

```mermaid
gantt
    title Timing
    dateFormat  mm-ss
    axisFormat  %M-%S
    section Round 1

    putflag (Round 1 flags) :r1p1, 00-00, 15s
    getflag (old flags)     :r0g2, 00-00, 15s

    getflag (old flags)     :r0g2, 00-30, 15s
    havoc                   :r1h1, 00-30, 15s
    putnoise                :r1pn1, 00-30, 15s

    getflag (Round 1 flags) :r1g1, 00-45, 15s
    getflag (old flags)     :r0g3, 00-45, 15s

    section Round 2

    putflag         :a1, 01-00, 15s

```

