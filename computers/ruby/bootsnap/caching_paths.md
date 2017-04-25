# Caching Paths

---

- [Overview](../bootsnap)
- [Caching Paths](../caching_paths)
- [Path Scanner](../path_scanner)

---

Caching paths is the main function of bootsnap. Previously, I mentioned that Bootsnap creates 2 caches:

- **Stable**: For Gems and Rubies since these are highly unlikely to change
- **Volatile**: For everything else, like your app code, since this is likely to change

This path is shown in the flowchart below. In a number of instances, `scan` is mentioned. This refers to the operation performed by the [Path Scanner](../path_scanner).


<!---
```diagram
graph TD

Entry[Starting Point]-\->pathInGem

subgraph Stability Check
  pathInGem[is the path in a gem?]--yes-\->Stable
  pathInGem--No-\->pathInRuby[is the path in a Ruby install?]
  pathInRuby--Yes-\->Stable
  pathInRuby--No-\->Volatile
end

subgraph Stable Cache
  Stable-\->GetStableEntriesDir[get entries and directories for path from cache]
  GetStableEntriesDir--got entries-\->StableCacheHit[Cache Hit!]
  StableCacheHit-\->StableReturn
  GetStableEntriesDir--did not get entries-\->StableCacheMiss[Cache Miss. Scan for entries and dirs. Expensive]
  StableCacheMiss-\->StoreStableCache[store result in cache with mtime of 0, since we dont use it for stable]
  StoreStableCache-\->StableReturn[ Return entries, dirs]
end

subgraph Volatile Cache
  Volatile-\->GetVolatileEntriesDir[get entries and directories for path from cache]
  GetVolatileEntriesDir-\->LatestMTime[Get latest mtime from dir and entries]
  LatestMTime--mtime = -1-\->ReturnEmpty[Path doesn't exist, return empty dir and entries]
  LatestMTime--mtime==cached_mtime-\->VolatileCacheHit[Cache Hit!]
  VolatileCacheHit-\->VolatileReturn[Return dir and entries]
  LatestMTime--else-\->VolatileCacheMiss[Cache Miss. Scan for entries and dirs. Expensive]
  VolatileCacheMiss-\->StoreVolatileCache[store result in cache with mtime intact since we use it for volatile cache]
  StoreVolatileCache-\->VolatileReturn
end
```
--->
<img src='http://jules2689.github.io/gitcdn/images/latex/0a9daea578e9a1b60cf49c6b226e444c.png' alt='diagram image' width='100%'>


### Mtimes (modified times) of files and directories

We do not take mtimes into account for stable caches. This is a more expensive operation so we avoid it when we can (this avoids as many filesystem calls as we can).

- This means for a "stable" cache, we simply use `0` as the mtime for all files, so there is no effect on the cache heuristic.
- For a "volatile" cache however, we find the maximum mtime of all files and directories in the given path. This means that if any file within a directory is added or removed, the cache is invalidated.
   - Note, the mtime is initialized at `-1`, so if the path doesn't exist, `-1` will be returned.
