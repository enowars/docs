# Welcome to Enowars

Enowars is an Engine for running A/D CTF events.

## Overview

[Specification](https://github.com/enowars/specification)

[Engine](https://github.com/enowars/EnoEngine)
Consists of EnoELK, EnoEngine, EnoLauncher

Eno ELK consists of
Elasticsearch (search engine, noSQL)

- Logstash (ingest and transform data)
- Kibana (webfrontend)

Eno Moloch

[ScoreBoard](https://github.com/enowars/EnoLandingPage)

[Services](https://github.com/enowars?q=enowars)

[EnoChecker](https://github.com/enowars/enochecker)



```mermaid
graph TB
    EnoLauncher
    EnoEngine
    EnoFlagSink
    EnoELK
    database[(Database)]
    router{Router}
    checker1[[Checker 1]]
    checker2[[Checker 2]]
    checker3[[Checker 3]]


    EnoLauncher -->|report| database
    EnoFlagSink --> database
    EnoEngine -->|send logs| EnoELK
    EnoEngine -->|send scoreboard data| EnoScoreboard
    EnoEngine -->|plan checks| database 
    EnoLauncher -->|run| checker1
    EnoLauncher -->|run| checker2
    EnoLauncher -->|run| checker3
    checker1 --> router
    checker2 --> router
    checker3 --> router
    router --> team1
    router --> team2
    router --> EnoFlagSink



    subgraph teams[Team Networks]
        team1
        team2
    end
```


--8<-- "includes/abbreviations.md"