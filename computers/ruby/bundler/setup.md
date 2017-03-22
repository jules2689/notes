# bundler/setup

Bundler setup parses through dependencies and compiles them into proper load paths. This step, on smaller applications, takes very little time. However on larger applications, this step can take a long duration - about 700-750ms to be exact.

Below are notes about how long certain parts take.

## Highest Level

```diagram
sequenceDiagram
bundler/setup->>require: "bundler/postit_trampoline" 6ms
bundler/setup->>require: "bundler/shared_helpers" 1.2ms
bundler/setup->>require: "bundler" 3ms
bundler/setup->>Bundler.setup: 700ms
bundler/setup->>Various: neglible time
```
