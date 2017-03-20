# Bootsnap

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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/432d52f1123c0bbd45090115ebfe12da.png' alt='diagram image'>

## Caching Paths

Caching paths is the main function of bootsnap. Previously, I mentioned that Bootsnap creates 2 caches:

- **Stable**: For Gems and Rubies since these are highly unlikely to change
- **Volatile**: For everything else, like your app code, since this is likely to change

This path is shown in the flowchart below:

```diagram
graph TD

Entry[Starting Point]-->pathInGem

subgraph Stability Check
  pathInGem[is the path in a gem?]--yes-->Stable
  pathInGem--No-->pathInRuby[is the path in a Ruby install?]
  pathInRuby--Yes-->Stable
  pathInRuby--No-->Volatile
end

subgraph Stable Cache
  Stable-->GetStableEntriesDir[get entries and directories for path from cache]
  GetStableEntriesDir--got entries-->StableCacheHit[Cache Hit!]
  StableCacheHit-->StableReturn
  GetEntriesDir--did not get entries-->StableCacheMiss[Cache Miss. Scan for entries and dirs. Expensive]
  StableCacheMiss-->StoreStableCache[store result in cache with mtime of 0, since we dont use it for stable]
  StoreStableCache-->StableReturn[ Return entries, dirs]
end

subgraph Volatile Cache
  Volatile-->GetVolatileEntriesDir[get entries and directories for path from cache]
  GetVolatileEntriesDir-->LatestMTime[Get latest mtime from dir and entries]
  LatestMTime--mtime = -1-->ReturnEmpty[Path doesn't exist, return empty dir and entries]
  LatestMTime--mtime==cached_mtime-->VolatileCacheHit[Cache Hit!]
  VolatileCacheHit-->VolatileReturn[Return dir and entries]
  LatestMTime--else-->VolatileCacheMiss[Cache Miss. Scan for entries and dirs. Expensive]
  VolatileCacheMiss-->StoreVolatileCache[store result in cache with mtime intact since we use it for volatile cache]
  StoreVolatileCache-->VolatileReturn
end
```

### Mtimes (modified times) of files and directories

We do not take mtimes into account for stable caches. This is a more expensive operation so we avoid it when we can (this avoids as many filesystem calls as we can).

- This means for a "stable" cache, we simply use `0` as the mtime for all files, so there is no effect on the cache heuristic.
- For a "volatile" cache however, we find the maximum mtime of all files and directories in the given path. This means that if any file within a directory is changed, the cache is invalidated.
   - Note, the mtime is initialized at `-1`, so if the path doesn't exist, `-1` will be returned.

