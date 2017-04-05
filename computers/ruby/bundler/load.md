# load

## initialize

A quick look at `load.setup` shows us that the `load` method takes a small amount of time `0.0016739999991841614s`. This means the bulk of the time is spent in `setup`.

## setup

This method took about `0.6628200000268407s` to run.

<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/runtime.rb method: setup
   numberFormat  %.2f

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
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/07e884f69afd901b12c0b51a28ef09f6.png' alt='diagram image' width='100%'>


As we can see, `specs = groups.any? ? @definition.specs_for(groups) : requested_specs` takes the most time (about 85% of the time).

Let's break that down a bit. I'll just change the turnary to an if/else and see what that produces.


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/runtime.rb method: setup
   numberFormat  %.2f

   "groups.map!(&:to_sym)" :a1, 0.000, 0.145
   "clean_load_path" :a1, 0.145, 0.290
   "specs = if groups.any?" :a1, 0.290, 0.435
   "requested_specs" :a1, 0.435, 82.871
   "SharedHelpers.set_bundle_environment" :a1, 82.871, 83.016
   "Bundler.rubygems.replace_entrypoints(specs)" :a1, 83.016, 88.346
   "load_paths = specs.map do |spec|" :a1, 88.346, 88.491
   "unless spec.loaded_from (run 375 times)" :a1, 88.491, 88.636
   "if (activated_spec = Bundler.rubygems.loaded_specs(spec.name)) && activated_spec.version != spec.version (run 375 times)" :a1, 88.636, 88.780
   "Bundler.rubygems.mark_loaded(spec) (run 375 times)" :a1, 88.780, 88.925
   "spec.load_paths.reject {|path| $LOAD_PATH.include?(path) } (run 804 times)" :a1, 88.925, 89.070
   "if insert_index = Bundler.rubygems.load_path_insert_index" :a1, 89.070, 89.215
   "$LOAD_PATH.insert(insert_index  *load_paths)" :a1, 89.215, 89.360
   "setup_manpath" :a1, 89.360, 91.577
   "lock(:preserve_unknown_sections => true)" :a1, 91.577, 99.855
   "self" :a1, 99.855, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/615f1c41da348502c193e68959692a37.png' alt='diagram image' width='100%'>


As we can see, `@definition.specs_for(groups)` is not even called. All the time is spent in `requested_specs`.

## requested_specs

It seems this delegates to `definition`.

In `definition`, this is the result:


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: requested_specs
   numberFormat  %.2f

   "end" :a1, 0.000, 0.173
   "groups = requested_groups" :a1, 0.173, 0.345
   "groups.map!(&:to_sym)" :a1, 0.345, 0.518
   "specs_for(groups)" :a1, 0.518, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/58d1e97c0e200461c936baaa53e3dafe.png' alt='diagram image' width='100%'>


Let's look at `specs_for`

## specs_for


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: specs_for
   numberFormat  %.2f

   "deps = dependencies.select {|d| (d.groups & groups).any? } (run 238 times)" :a1, 0.000, 0.152
   "deps.delete_if {|d| !d.should_include? } (run 238 times)" :a1, 0.152, 0.305
   "specs.for(expand_dependencies(deps))" :a1, 0.305, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/787a9e70bd8caab794f9928d1c62ddd8.png' alt='diagram image' width='100%'>


`specs.for(expand_dependencies(deps))` takes the most time, but is it the `specs.for` part, or the `expand_dependencies` part?

It is the `specs.for` part:


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: specs_for
   numberFormat  %.2f

   "deps = dependencies.select {|d| (d.groups & groups).any? } (run 238 times)" :a1, 0.000, 0.167
   "deps.delete_if {|d| !d.should_include? } (run 238 times)" :a1, 0.167, 0.334
   "d = expand_dependencies(deps)" :a1, 0.334, 0.854
   "specs.for(d)" :a1, 0.854, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/25a37703789441a3502a3f0cac608356.png' alt='diagram image' width='100%'>

## specs.for

```
gantt
   title file: /development/opensource/bundler/lib/bundler/spec_set.rb method: for
   numberFormat  %.2f

   "handled = {} (run 4 times)" :a1, 0.000, 0.923
   "deps = dependencies.dup (run 4 times)" :a1, 0.923, 1.847
   "specs = [] (run 4 times)" :a1, 1.847, 2.770
   "skip += ['bundler'] (run 4 times)" :a1, 2.770, 3.693
   "loop do (run 4 times)" :a1, 3.693, 4.617
   "break unless dep = deps.shift (run 1834 times)" :a1, 4.617, 5.540
   "if spec = lookup['bundler'].first (run 4 times)" :a1, 5.540, 6.463
   "next if handled[dep] || skip.include?(dep.name) (run 1830 times)" :a1, 6.463, 7.387
   "handled[dep] = true (run 1821 times)" :a1, 7.387, 8.310
   "if spec = spec_for_dependency(dep  match_current_platform) (run 1821 times)" :a1, 8.310, 9.234
   "specs << spec (run 1821 times)" :a1, 9.234, 10.157
   "spec.dependencies.each do |d| (run 1821 times)" :a1, 10.157, 95.383
   "next if d.type == :development (run 28 times)" :a1, 95.383, 96.307
   "d = DepProxy.new(d  dep.__platform) unless match_current_platform (run 27 times)" :a1, 96.307, 97.230
   "deps << d (run 27 times)" :a1, 97.230, 98.153
   "specs << spec" :a1, 98.153, 99.077
   "check ? true : SpecSet.new(specs)" :a1, 99.077, 100.000
```

## specs


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: specs_for
   numberFormat  %.2f

   "deps = dependencies.select {|d| (d.groups & groups).any? } (run 238 times)" :a1, 0.000, 0.165
   "deps.delete_if {|d| !d.should_include? } (run 238 times)" :a1, 0.165, 0.330
   "d = expand_dependencies(deps)" :a1, 0.330, 0.836
   "s = specs" :a1, 0.836, 75.406
   "s.for(d)" :a1, 75.406, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/1e0e32865dd876d5e30abcfb8a5720e9.png' alt='diagram image' width='100%'>


As we can see, about 3/4 of the time is spent making the specs, and 1/4 of the time processing with `for`.

## specs


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: specs
   numberFormat  %.2f

   "end" :a1, 0.000, 0.223
   "begin" :a1, 0.223, 0.445
   "specs = resolve.materialize(Bundler.settings[:cache_all_platforms] ? dependencies : requested_dependencies)" :a1, 0.445, 92.952
   "unless specs['bundler'].any?" :a1, 92.952, 95.996
   "local = Bundler.settings[:frozen] ? rubygems_index : index" :a1, 95.996, 99.286
   "bundler = local.search(Gem::Dependency.new('bundler'  VERSION)).last" :a1, 99.286, 99.555
   "specs['bundler'] = bundler if bundler" :a1, 99.555, 99.777
   "specs" :a1, 99.777, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/d5e1e5092bb91951c29c59dc88ad2c72.png' alt='diagram image' width='100%'>


This line does quite a lot (`resolve.materialize(Bundler.settings[:cache_all_platforms] ? dependencies : requested_dependencies)`), so let's split it up.


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/definition.rb method: specs
   numberFormat  %.2f

   "end" :a1, 0.000, 0.222
   "begin" :a1, 0.222, 0.444
   "r = resolve" :a1, 0.444, 37.415
   "deps = if Bundler.settings[:cache_all_platforms]" :a1, 37.415, 37.637
   "requested_dependencies" :a1, 37.637, 37.859
   "specs = r.materialize(deps)" :a1, 37.859, 93.610
   "unless specs['bundler'].any?" :a1, 93.610, 96.213
   "local = Bundler.settings[:frozen] ? rubygems_index : index" :a1, 96.213, 99.286
   "bundler = local.search(Gem::Dependency.new('bundler'  VERSION)).last" :a1, 99.286, 99.556
   "specs['bundler'] = bundler if bundler" :a1, 99.556, 99.778
   "specs" :a1, 99.778, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/a4abdd379f1207b63fab6d37ec66088a.png' alt='diagram image' width='100%'>


As we can see, `resolve` and `materialize` take the most time.

---

Materializing
---

| line | num_calls | time (s) |
| ---- | --------- | -------- |
| resolve | 73 | 0.05524000007426366 |
| materialize | 1 | 0.1665900000371039 |
| __materialize__ | 374 | 0.15040999941993505 |
| specs | 374 | 0.13627100008307025 |
| rubygems spec | 296 | 0.03416500013554469 |
| git specs | 293 | 0.09133500000461936 |
| search | 596 | 0.012452999944798648 |



<!---
```diagram
graph TD
  materialize -- 150ms -\-> __materialize__
  __materialize__ -- 136ms -\-> specs
  
  subgraph __materialize__
    specs -- 34ms -\-> rubygems_specs[RubyGems specs]
    specs -- 91ms -\-> git_specs[Git Specs]
    __materialize__ -- 12ms -\-> search
  end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/005fba5b5ad80e50382313df2a1f4aaf.png' alt='diagram image' height="400">

## git-based specs


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler/source/path.rb method: load_spec_files
   numberFormat  %.2f

   "index = Index.new (run 71 times)" :a1, 0.000, 0.922
   "if File.directory?(expanded_path) (run 71 times)" :a1, 0.922, 8.775
   "Dir['#{expanded_path}/#{@glob}'].sort_by {|p| -p.split(File::SEPARATOR).size }.each do |file| (run 153 times)" :a1, 8.775, 23.952
   "next unless spec = Bundler.load_gemspec(file) (run 82 times)" :a1, 23.952, 94.468
   "spec.source = self (run 82 times)" :a1, 94.468, 95.390
   "Bundler.rubygems.set_installed_by_version(spec) (run 82 times)" :a1, 95.390, 96.312
   "validate_spec(spec) (run 82 times)" :a1, 96.312, 97.234
   "index << spec (run 82 times)" :a1, 97.234, 98.156
   "if index.empty? && @name && @version (run 71 times)" :a1, 98.156, 99.078
   "index" :a1, 99.078, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/07b61084e06c0c400a0ba5b6a548fc23.png' alt='diagram image' width='100%'>


We can see that we load 82 gemspecs - which takes the most time. Can we cache loading those gemspecs? They aren't going to change in between loads.

Globbing the filesystem also takes a chunk of time (`Dir['#{expanded_path}/#{@glob}'].sort_by {|p| -p.split(File::SEPARATOR).size }`) - about 15% of 91ms to be exact.

## load_gemspec


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler.rb method: load_gemspec
   numberFormat  %.2f

   "@gemspec_cache ||= {} (run 82 times)" :a1, 0.000, 1.374
   "key = File.expand_path(file) (run 82 times)" :a1, 1.374, 2.748
   "@gemspec_cache[key] ||= load_gemspec_uncached(file  validate) (run 82 times)" :a1, 2.748, 98.626
   "@gemspec_cache[key].dup if @gemspec_cache[key]" :a1, 98.626, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/28b3399c87fa8b4a55749e53e1e3e3b4.png' alt='diagram image' width='100%'>



## load_gemspec_uncached


<!---
```diagram
gantt
   title file: /src/github.com/jules2689/bundler/lib/bundler.rb method: load_gemspec_uncached
   numberFormat  %.2f

   "path = Pathname.new(file) (run 82 times)" :a1, 0.000, 1.315
   "SharedHelpers.chdir(path.dirname.to_s) do (run 82 times)" :a1, 1.315, 2.631
   "contents = path.read (run 82 times)" :a1, 2.631, 3.946
   "spec = if contents[0..2] == '---' # YAML header (run 82 times)" :a1, 3.946, 5.262
   "eval_gemspec(path  contents) (run 82 times)" :a1, 5.262, 94.738
   "return unless spec (run 82 times)" :a1, 94.738, 96.054
   "spec.loaded_from = path.expand_path.to_s (run 82 times)" :a1, 96.054, 97.369
   "Bundler.rubygems.validate(spec) if validate (run 82 times)" :a1, 97.369, 98.685
   "spec" :a1, 98.685, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/51fcc2cac0589579c867445fcd5b7dd8.png' alt='diagram image' width='100%'>

