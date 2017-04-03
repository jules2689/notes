# load

## initialize

A quick look at `load.setup` shows us that the `load` method takes a small amount of time `0.0016739999991841614s`. This means the bulk of the time is spent in `setup`.

## setup

This method took about `0.6628200000268407s` to run.

```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/runtime.rb method: setup
   dateFormat  s.SSS

   "groups.map!(&:to_sym)" :a1, 0.000, 0.151
   "clean_load_path" :a1, 0.151, 0.302
   "specs = groups.any? ? @definition.specs_for(groups) : requested_specs" :a1, 0.302, 85.592
   "SharedHelpers.set_bundle_environment" :a1, 85.592, 85.743
   "Bundler.rubygems.replace_entrypoints(specs)" :a1, 85.743, 90.408
   "load_paths = specs.map do |spec|" :a1, 90.408, 90.559
   "unless spec.loaded_from (run 375 times)" :a1, 90.559, 90.710
   "if (activated_spec = Bundler.rubygems.loaded_specs(spec.name)) && activated_spec.version != spec.version (run 375 times)" :a1, 90.710, 90.861
   "Bundler.rubygems.mark_loaded(spec) (run 375 times)" :a1, 90.861, 91.012
   "spec.load_paths.reject {|path| $LOAD_PATH.include?(path) } (run 804 times)" :a1, 91.012, 91.163
   "if insert_index = Bundler.rubygems.load_path_insert_index" :a1, 91.163, 91.314
   "$LOAD_PATH.insert(insert_index  *load_paths)" :a1, 91.314, 91.465
   "setup_manpath" :a1, 91.465, 93.292
   "lock(:preserve_unknown_sections => true)" :a1, 93.292, 99.849
   "self" :a1, 99.849, 100.000
```
