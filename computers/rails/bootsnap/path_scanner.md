# Caching Paths

---

- [Overview](../bootsnap)
- [Caching Paths](../caching_paths)
- [Path Scanner](../path_scanner)

---

The Path Scanner is intended to identify all files and folders within a given path that are not in the bundler path already. As a result, we can then use this result to cache path loading.




<!---
```diagram
graph TD
  StartPoint[Starting Point]-\->Relative?
  Relative?[is path relative?]--yes-\->Error[raise RelativePathNotSupported error]
  Relative?--no-\->DirListing[iterator for all requirables from path]
  DirListing--Next entry-\->DescendentOfBundlePath[bundle path is a descendent of this path?**]
  DirListing--No next entry-\->Return[return dirs and requireables]

subgraph Directory Glob
  DescendentOfBundlePath--yes-\->DirListing
  DescendentOfBundlePath--no-\->Dir?
  AddDir-\->DirListing
  AddRequireable-\->DirListing
  Dir?--yes-\->AddDir[Add to dirs]
  Dir?--no-\->AddRequireable[Add to requireables]
end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/9cb9b39adf4bf924c16adbb0ef246aa4.png' alt='diagram image' width='100%'>

** If the bundle path is a descendent of this path, we do additional checks to prevent recursing into the bundle path as we recurse through this path. We don't want to scan the bundle path because anything useful in 

