# Service & Checker Tenets

In the following we are using [RFC2119](https://www.ietf.org/rfc/rfc2119.txt) Key word to specify the Service and Checker capabilities.

!!! info
    🔴MUST   This word, or the terms "REQUIRED" or "SHALL", mean that the
    definition is an absolute requirement of the specification.

    🔴MUST NOT   This phrase, or the phrase "SHALL NOT", mean that the
    definition is an absolute prohibition of the specification.

    🟡SHOULD   This word, or the adjective "RECOMMENDED", mean that there
    may exist valid reasons in particular circumstances to ignore a
    particular item, but the full implications must be understood and
    carefully weighed before choosing a different course.

    🟡SHOULD NOT   This phrase, or the phrase "NOT RECOMMENDED" mean that
    there may exist valid reasons in particular circumstances when the
    particular behavior is acceptable or even useful, but the full
    implications should be understood and the case carefully weighed
    before implementing any behavior described with this label.

    🟢MAY   This word, or the adjective "OPTIONAL", mean that an item is
    truly optional.  One vendor may choose to include the item because a
    particular marketplace requires it or because the vendor feels that
    it enhances the product while another vendor may omit the same item.
    An implementation which does not include a particular option MUST be
    prepared to interoperate with another implementation which does
    include the option, though perhaps with reduced functionality. In the
    same vein an implementation which does include a particular option
    MUST be prepared to interoperate with another implementation which
    does not include the option (except, of course, for the feature the
    option provides.)

## Service

A service:

 - 🔴 MUST be able to store and load flags for a specified number of rounds
 - 🔴 MUST NOT lose flags if it is restarted
 - 🔴 MUST be rebuilt as fast as possible, no redundant build stages should be executed every time the service is built
 - 🔴 MUST be able to endure the expected load
 - 🟡 SHOULD NOT be a simple wrapper for a key-value database, and SHOULD expose more complex functionality
 - 🟡 SHOULD NOT rewritable within within the timeframe of the contest
 - 🟢 MAY be written in unexpected languages or using fun frameworks

### Vulnerabilities

A service: 

 - 🔴 MUST have at least one complex vulnerability
 - 🔴 MUST have at least one "location" where flags are stored (called flag store)
 - 🟡 SHOULD have more than one vulnerability
 - 🟡 SHOULD NOT have unintended vulnerabilities
 - 🟡 SHOULD NOT have vulnerabilities that allow the deletion but not the retrieval of flags
 - 🟡 SHOULD NOT have vulnerabilities that allow only one attacker to extract a flag
 - 🟢 MAY have additional flag stores, which requires a separate exploit to extract flags


A vulnerability:

 - 🔴 MUST be exploitable and result in a correct flag
 - 🔴 MUST stay exploitable over the course of the complete game (I.e. auto delete old flags, if necessary) 
 - 🔴 MUST be fixable with reasonable effort and without breaking the checker
 - 🔴 MUST be exploitable without renting excessive computing resources
 - 🔴 MUST be expoitable with reasonable amounts of network traffic
 - 🟡 SHOULD NOT be easily replayable 

## Checker

A checker: 

- 🔴 MUST check whether a flag is retrievable, and MUST NOT fail if the flag is retrievable, and MUST fail if the flag is not retrievable
- 🔴 MUST NOT rely on information stored in the service in rounds before the flag was inserted
- 🔴 MUST NOT crash or return unexpected results under any circumstances
- 🔴 MUST log sufficiently detailed information that operators can handle complaints from participants
- 🔴 MUST check the entire functionality of the service and report faulty behavior, even unrelated to the vulnerabilities
- 🟡 SHOULD not be easily identified by the examination of network traffic
- 🟡 SHOULD use unusual, incorrect or pseudomalicious input to detect network filters
- 🟢 MAY use information stored in previous rounds, if it gracefully handles the unexpected absence of that information
