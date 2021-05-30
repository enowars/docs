# Welcome to Enowars

Enowars is a Framework for running A/D CTF events.

## Overview

### Infrastructure

Everything is running in the cloud thats why we have s
### Services and Checkers

> Previous [Services](https://github.com/enowars?q=enowars) can be found on our [Github Page](https://github.com/enowars?q=enowars)

To develop a new one follow our [guide](service/getting-started.md). 

[EnoChecker](https://github.com/enowars/enochecker)







```mermaid
graph TB
    EnoLauncher
    EnoEngine
    EnoFlagSink
    EnoELK
    database[(Database)]
    router{Router}
    checker1[[Checker 1..N]]


    router --> team
    router --> EnoFlagSink
    EnoEngine -->|send logs| EnoELK
    EnoEngine -->|send scoreboard data| EnoScoreboard
    EnoEngine -->|plan checks| database
    database -->|get reports| EnoEngine
    EnoLauncher -->|run| checker1
    EnoLauncher -->|report| database
    EnoFlagSink --> database
    checker1 --> router
    checker1 -->|send logs| EnoELK



    subgraph teams[Team Networks]
        team[Team 1..N]
    end
```



> TBD: [Specification](https://github.com/enowars/specification)

--8<-- "includes/abbreviations.md"