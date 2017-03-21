# Bootsnap

---

- [Overview](../bootsnap)
- [Caching Paths](../caching_paths)
- [Path Scanner](../path_scanner)

---

Bootsnap is a library that overrides `Kernel#require`, `Kernel#load`, `Module#autoload` and in the case that `ActiveSupport` is used, it will also override a number of `ActiveSupport` methods.

Bootsnap creates 2 kinds of caches, a stable, long lived cache out of Ruby and Gem directories. These are assumed to *never* change and so we can cache more aggresively. Application code is expected to change frequently, so it is cached with little aggression (short lived bursts that should last only as long as the app takes to boot). This is the "volatile" cache.

Below is a diagram explaining how the overrides work.



<!---
```diagram
graph TD

subgraph Bootsnap Object
  cache
  autoload_path_cache
  store-\->cache
end

subgraph ActiveSupport
  depend_onSuper[depend_on]
  load_missing_constantSuper[load_missing_constant]
  remove_constantSuper[remove_constant]
  search_for_fileSuper[search_for_file]
end

subgraph ActiveSupport Overrides
  autoload_path=--reinitializes-\->autoload_path_cache
  autoloadable_module?-.has_dir?.->autoload_path_cache
  search_for_file-.with cache.->autoload_path_cache
  search_for_file-.without cache.->search_for_fileSuper
  search_for_file-\->remove_constant
  remove_constant-.->remove_constantSuper

  depend_onExt[depend_on]
  load_missing_constantExt[load_missing_constant]

  load_missing_constant-.->load_missing_constantExt
  depend_on-.->depend_onExt

  depend_onExt-.rescue LoadError.->depend_onSuper
  load_missing_constantExt-.rescue NameError.->load_missing_constantSuper
end

subgraph Kernel Require Overrides
  Kernel#require-.->cache
  Kernel#load-.->cache
  Module#autoload-.->cache
end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/432d52f1123c0bbd45090115ebfe12da.png' alt='diagram image' width='100%'>



In this diagram, you might notice that we refer to `cache` and `autoload_path_cache` as the main points of override. These are calculated using the concepts described in [Caching Paths](../caching_paths).