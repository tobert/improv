# improv

NOTE: Just spitballing some ideas at the moment and this is all likely
to change as the code comes together.

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

Actors are plain old processes, exactly like scripting pipes in shell scripts.
If a script ends in recognized suffix, e.g. .py/.pl/.js, it is automatically
combined with a stub script to set up the main loop and JSON serdes so that
the code you write is a single function that accepts a message that is the
deserialized JSON (which will probably look a lot like JSON-RPC).

If you don't want to use the stub that's fine. Just leave the extension off
the script or set "stub" to false in the actor definition.

```
{
    "improv": {
        "global_config_key": "global_config_value"
    },
    "actors": [
        {
            "name": "read_db",
            "code": "./scripts/read_db.pl",
            "env": { "DB_USER": "syn", "DB_PASS": "kronos", "DB_NAME": "supers" },
            "args": [ "--format", "csv" ]
        },
        {
            "name": "ranker",
            "interpreter": "/bin/env python3",
            "code": "./scripts/rank_supers_csv.py"
        },
        {
            "name": "probe",
            "code": "./scripts/probe_super.js",
            "comment": "Scripts are combined with a stub program by default. This may be disabled.",
            "stub": false
        },
        {
            "comment": "batchmode is automatically enabled and tty is disabled by default",
            "name": "ssh-to-bastion",
            "code": "ssh",
            "args": [ "-A", "tobert@brak.tobert.org" ]
        }
    ],

    "topology": {
        "stdin": ["ssh-to-bastion"],
        "ssh-to-bastion": ["read_db"],
        "read_db": ["ranker"],
        "ranker": ["probe"]
    }
}
```

## assumptions / conventions

Some actors are built in, such as "stdin" and "ssh". Some others
will be added as this thing grows, probably including file IO
(e.g. something like dd or cat) and a simple global key/value
store.

When in doubt, optimize for quick iteration.

* stdin/stdout only
    * gracefully handle noise on stdout
    * only emit strict protocol to stdin of actors
* json encoding only
* assume long-lived event processing
* allow for efficient short-lived scripting-style usage

## someday

* add a built-in ssh client (e.g. for windows)

## related

* https://github.com/tobert/sprok
* https://github.com/tobert/nodule
* GNU parallel, xargs

