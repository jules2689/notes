## Caching Paths

---

- [Overview](../bootsnap)
- [Caching Paths](../caching_paths)
- [Path Scanner](../path_scanner)

---

The Path Scanner is intended to identify all files and folders within a given path that are not in the bundler path already. As a result, we can then use this result to cache path loading.


```diagram
graph TD
  StartPoint[Starting Point]-->Relative?
  Relative?[is path relative?]--yes-->Error[raise RelativePathNotSupported error]
  Relative?--no-->DirListing[iterator for all requirables from path]
  DirListing--Next entry-->StartWithBundlePath[starts with bundle path?]
  DirListing--No next entry-->Return[return dirs and requireables]

subgraph Directory Glob
  StartWithBundlePath--yes-->DirListing
  StartWithBundlePath--no-->Dir?
  AddDir-->DirListing
  AddRequireable-->DirListing
  Dir?--yes-->AddDir[Add to dirs]
  Dir?--no-->AddRequireable[Add to requireables]
end
```

