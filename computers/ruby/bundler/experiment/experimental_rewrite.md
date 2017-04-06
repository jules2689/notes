# Experimental Rewrite

# WIP

MVP includes:

- gem support
- source support
- group support

## bundle install


<!---
```diagram
graph TD
 bundle_install[bundle install]-\->compare[Gemfile == Gemfile.lock]
 compare--yes-\->makesure[are all gems in lockfile installed?]
 makesure--yes-\->done
 makesure--no-\->install[install missing gems]
 install-\->makesure
 compare--no-\->resolve[resolve differences to Gemfile.lock]
 resolve-\->makesure
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/6b39bed85de3d3cb24187e43db6e5a90.png' alt='diagram image' height='400'>


This is a very naive approach as it doesn't really take into account resolving nested dependencies in gemspecs.

The `lockfile` is consisted of a very simple file in the following format for easy parsing:
```
checksum 12345abcdef
gem_name gem_version
gem_name gem_version
gem_name gem_version
gem_name gem_version
```

# WIP