# improv

Improv is an actor system comprised of OS processes that communicate
over pipes. Improv aims to only provide the infrastructure
necessary to string together processes. The difference from
shell scripts are that improv topologies are declarative and may be
remote over ssh or a similar protocol.

The goal is to be able to feed data into improv's stdin along with
a topology definition and have it do all the rest, returning any
output on stdout. ssh connections should be automatically started.

## contrived example

Something like this. I might decide to go with separate declaration
of scripts/args then a separate key for defining the graph.

maybe connection setup should just be another script...

Need to decide whether to simply lean into git for distributing the
code or whether to simply push it out scp style. For code that has
dependencies, just start a Docker container and let the docker repo
sort things out. But even with Docker in play simple Go programs
or script with no need to bundle dependencies should just work without
having to go through docker-ization.

```
improv -t incredible.json
```

```
{
    "stdin": [
        {
            "code": "./scripts/read_db.pl",
            "env": { "DB_USER": "syn", "DB_PASS": "kronos", "DB_NAME": "supers" },
            "args": [ "--format", "csv" ]
        }
    ],
    "stdout": [
        { "name": "ranker", "code": "./scripts/rank_supers_csv.py" }
    ],
    "ranker": [
        { "name": "probe", "code": "./scripts/probe_super.js" }
    ]
}
```

## requirements

* stdin/stdout only
    * gracefully handle noise on stdout
    * only emit strict protocol to stdin of actors
* json encoding only
* only local and ssh connections are supported
    * defaults to system ssh
    * make it possible to replace with e.g. netcat, stunnel, etc.
* assume long-lived event processing
* allow for efficient short-lived scripting-style usage

## someday

* add a built-in ssh client (e.g. for windows)

## related

* https://github.com/tobert/nodule
* GNU parallel, xargs

