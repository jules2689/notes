# bundler/definition.rb

```diagram
graph TD
   Bundler#definition[Bundler#definition 226ms]--120ms-->Definition.build
   Definition.build--118ms-->Dsl#evaluate
   Dsl#evaluate--33ms-->builder.eval_gemfile
   Dsl#evaluate--85ms-->Definition#new[builder.to_definition -> Definition#new]
   Definition#new--33ms-->LockfileParser.new
   Definition#new--35ms-->definition#converge_dependencies
   definition#converge_dependencies--113K calls, 30ms-->locked_deps.select
   LockfileParser.new--1370 calls, 26ms-->lockfile_parser#parse_state
   lockfile_parser#parse_state--1131 times, 22ms-->lockfile_parser#parse_source
   lockfile_parser#parse_state--1 times, <1ms-->lockfile_parser#parse_platform
   lockfile_parser#parse_state--237 times, 5ms-->lockfile_parser#parse_dependency
   lockfile_parser#parse_state--1 times, <1ms-->lockfile_parser#parse_bundled_with
   lockfile_parser#parse_source--854 calls, about 15ms-->lockfile_parser#parse_spec
   lockfile_parser#parse_spec--374 calls, 7.5ms-->NAME_VERSION_4
   lockfile_parser#parse_spec--480 calls, 7.5ms-->NAME_VERSION_6
   NAME_VERSION_4--6ms-->current_spec.source
   NAME_VERSION_6--2ms-->Gem::Dependency.new(name, version)
   NAME_VERSION_6--6ms-->specs=current_spec
```

---

Bundler#definition
---

<!---
```diagram
gantt
   title file: gems/bundler-1.14.5/lib/bundler.rb method: definition
   dateFormat  s.SSS

   @definition = nil if unlock :a1, 0.000, 0.001
   end :a1, 0.001, 0.002
   configure :a1, 0.002, 0.016
   Definition.build(default_gemfile, default_lockfile, unlock) :a1, 0.016, 0.226
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/23b676377c99e839cbedb08ef02c2580.png' alt='diagram image' width='100%'>


As we can see, `Definition.build` take a long time to process.

---

Definition.build
---

<!---
```diagram
gantt
   title lib/bundler/definition.rb#build
   dateFormat  s.SSS

   unlock ||= {} :a1, 0.000, 0.001
   gemfile = Pathname.new(gemfile).expand_path :a1, 0.001, 0.002
   raise GemfileNotFound :a1, 0.002, 0.003
   Dsl.evaluate(gemfile, lockfile, unlock) :a1, 0.003, 0.214
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/8e82477f959f767a7fd4cf8c58b1f5fb.png' alt='diagram image' width='100%'>

From here we can see `Dsl.evaluate` takes the most time

---

Dsl.evaluate
---

<!---
```diagram
gantt
   title lib/bundler/dsl.rb#evaluate
   dateFormat  s.SSS

   builder = new :a1, 0.000, 0.001
   builder.eval_gemfile(gemfile) :a1, 0.001, 0.056
   builder.to_definition(lockfile, unlock) :a1, 0.056, 0.185
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/9a323efe751f19d3f0e6b0a4664dcc77.png' alt='diagram image' width='100%'>

We can see that the time is split between `eval_gemfile` and `to_definition`.

---

builder.eval_gemfile
---

<!---
```diagram
gantt
   title lib/bundler/dsl.rb#eval_gemfile
   dateFormat  s.SSS

   begin :a1, 0.000, 0.001
   expanded_gemfile_path = ... :a1, 0.001, 0.002
   original_gemfile = @gemfile :a1, 0.002, 0.003
   @gemfile = expanded_gemfile_path :a1, 0.003, 0.004
   contents ||= Bundler.read_file(gemfile.to_s) :a1, 0.004, 0.005
   instance_eval :a1, 0.005, 0.058
   @gemfile = original_gemfile :a1, 0.058, 0.059
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/8442a36a5b4f4f43b6a2bddecca3dca7.png' alt='diagram image' width='100%'>


We can see here that when we take the contents of the bundler file, and `instance_eval` it, we'll spend about 55ms doing that.

Digging into the `instance_eval` a little more using `TracePoint`, we can see that there are hundreds of mini-methods called starting with `dsl#source`. We get this approximate trace:

```ruby
[161, Bundler::Dsl, :source, :call]
[336, Bundler::Dsl, :normalize_hash, :call]
[435, Bundler::Dsl, :normalize_source, :call]
[449, Bundler::Dsl, :check_primary_source_safety, :call]
[90, Bundler::SourceList, :rubygems_primary_remotes, :call]
[38, Bundler::SourceList, :add_rubygems_remote, :call]
[210, Bundler::Source::Rubygems, :add_remote, :call]
...
[115, Bundler::SourceList, :warn_on_git_protocol, :call]
[245, #<Class:Bundler>, :settings, :call]
[54, Bundler::Settings, :[], :call]
[224, Bundler::Settings, :key_for, :call]
[325, Bundler::Dsl, :with_source, :call]
[79, Bundler::Dependency, :initialize, :call]
[38, Gem::Dependency, :initialize, :call]
...
[54, #<Class:Gem::Requirement>, :create, :call]
[123, Gem::Requirement, :initialize, :call]
[121, Bundler::Dsl, :gem, :call]
[347, Bundler::Dsl, :normalize_options, :call]
[336, Bundler::Dsl, :normalize_hash, :call]
[343, Bundler::Dsl, :valid_keys, :call]
[418, Bundler::Dsl, :validate_keys, :call]
[209, Bundler::Dsl, :git, :call]
[336, Bundler::Dsl, :normalize_hash, :call]
[24, Bundler::SourceList, :add_git_source, :call]
[13, Bundler::Source::Git, :initialize, :call]
[96, Bundler::SourceList, :add_source_to_list, :call]
[49, Bundler::Source::Git, :hash, :call]
[79, Bundler::Source::Git, :name, :call]
[49, Bundler::Source::Git, :hash, :call]
[79, Bundler::Source::Git, :name, :call]
... repeat the last block a lot, particularly Bundler::Source::Git calls ...
[115, Bundler::SourceList, :warn_on_git_protocol, :call]
[245, #<Class:Bundler>, :settings, :call]
[54, Bundler::Settings, :[], :call]
[224, Bundler::Settings, :key_for, :call]
[325, Bundler::Dsl, :with_source, :call]
[79, Bundler::Dependency, :initialize, :call]
[38, Gem::Dependency, :initialize, :call]
```

Without optimizing dozens of places, this is likely a dead end. We can look at caching, but it is uncacheable. Due to extensive use of procs and default values in hashes, we cannot cache the class object.

This is a dead end.

---

builder.to_definition
---

This method simply calls `Definition.new`, so we'll move to that instead.

---

Definition.new
---

<!---
```diagram
gantt
   title lib/bundler/definition.rb#initialize
   dateFormat  s.SSS

   @unlocking = unlock == true || !unlock.empty? :a1, 0.000, 0.001
   @dependencies    = dependencies :a1, 0.001, 0.002
   @sources         = sources :a1, 0.002, 0.003
   @unlock          = unlock :a1, 0.003, 0.004
   @optional_groups = optional_groups :a1, 0.004, 0.005
   @remote          = false :a1, 0.005, 0.006
   @specs           = nil :a1, 0.006, 0.007
   @ruby_version    = ruby_version :a1, 0.007, 0.008
   @lockfile               = lockfile :a1, 0.008, 0.009
   @lockfile_contents      = String.new :a1, 0.009, 0.010
   @locked_bundler_version = nil :a1, 0.010, 0.011
   @locked_ruby_version    = nil :a1, 0.011, 0.012
   if lockfile && File.exist?(lockfile) :a1, 0.012, 0.013
   @lockfile_contents = Bundler.read_file(lockfile) :a1, 0.013, 0.014
   @locked_gems = LockfileParser.new(@lockfile_contents) :a1, 0.014, 0.062
   @locked_platforms = @locked_gems.platforms :a1, 0.062, 0.063
   @platforms = @locked_platforms.dup :a1, 0.063, 0.064
   @locked_bundler_version = @locked_gems.bundler_version :a1, 0.064, 0.065
   @locked_ruby_version = @locked_gems.ruby_version :a1, 0.065, 0.066
   if unlock != true :a1, 0.066, 0.067
   @locked_deps    = @locked_gems.dependencies :a1, 0.067, 0.068
   @locked_specs   = SpecSet.new(@locked_gems.specs) :a1, 0.068, 0.070
   @locked_sources = @locked_gems.sources :a1, 0.070, 0.071
   @unlock[:gems] ||= [] :a1, 0.071, 0.072
   @unlock[:sources] ||= [] :a1, 0.072, 0.073
   @unlock[:ruby] ||= if @ruby_version && locked_ruby_version_object :a1, 0.073, 0.074
   @unlocking ||= @unlock[:ruby] ||= (!@locked_ruby_version ^ !@ruby_version) :a1, 0.074, 0.075
   add_current_platform unless Bundler.settings[:frozen] :a1, 0.075, 0.076
   converge_path_sources_to_gemspec_sources :a1, 0.076, 0.094
   @path_changes = converge_paths :a1, 0.094, 0.095
   @source_changes = converge_sources :a1, 0.095, 0.109
   unless @unlock[:lock_shared_dependencies] :a1, 0.109, 0.110
   eager_unlock = expand_dependencies(@unlock[:gems]) :a1, 0.110, 0.111
   @unlock[:gems] = @locked_specs.for(eager_unlock).map(&:name) :a1, 0.111, 0.112
   @gem_version_promoter = create_gem_version_promoter :a1, 0.112, 0.113
   @dependency_changes = converge_dependencies :a1, 0.113, 0.181
   @local_changes = converge_locals :a1, 0.181, 0.182
   @requires = compute_requires :a1, 0.182, 0.183
   fixup_dependency_types! :a1, 0.183, 0.194
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/b09f829c9ab8241be0bf624e1fccb56e.png' alt='diagram image' width='100%'>

Taking some of the more "expensive" lines, we can dig a bit deeper to get more accurate numbers.

| line | num_calls | time (s) |
| --- | --- | --- |
| @locked_gems = LockfileParser.new(@lockfile_contents), :a1, , | 1 | 0.03465300000971183 |
| @locked_specs   = SpecSet.new(@locked_gems.specs), :a1, , | 1 | 0.002618999977130443 |
| converge_path_sources_to_gemspec_sources, :a1, , | 1 | 0.006308999989414588 |
| @source_changes = converge_sources, :a1, , | 1 | 0.010037000000011176 |
| @dependency_changes = converge_dependencies, :a1, , | 1 | 0.022082999988924712 |
| fixup_dependency_types!, :a1, , | 1 | 0.0025529999984428287 |

---

LockfileParser.new
---

See [lockfile_parser](../lockfile_parser)

---

definition#coverge_dependencies
---


```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/definition.rb method: converge_dependencies
   dateFormat  s.SSS

   "(@dependencies + @locked_deps.values).each do |dep|" :a1, 0.000, 0.001
   "locked_source = @locked_deps[dep.name] (run 474 times)" :a1, 0.001, 0.002
   "if Bundler.settings[:frozen] && !locked_source.nil? && (run 474 times)" :a1, 0.002, 0.005
   "elsif dep.source (run 474 times)" :a1, 0.005, 0.006
   "dep.source = sources.get(dep.source) (run 142 times)" :a1, 0.006, 0.009
   "if dep.source.is_a?(Source::Gemspec) (run 474 times)" :a1, 0.009, 0.010
   "dependency_without_type = proc {|d| Gem::Dependency.new(d.name  *d.requirement.as_list) } (run 475 times)" :a1, 0.010, 0.026
   "Set.new(@dependencies.map(&dependency_without_type)) != Set.new(@locked_deps.values.map(&dependency_without_type))" :a1, 0.026, 0.027
```

It is very obvious to see that this particular line `locked_source = @locked_deps.select {|d| d.name == dep.name }.last (run 112812 times) :a1, 0.001, 0.182` is the root cause of the slowness.
Run 112-113K times for the Shopify application, it is slow and could likely benefit from some up front hashing.

This particular line was fixed by [this pull request](https://github.com/bundler/bundler/pull/5539).

After fixing the issue surrounding select, my attention turned to `dependency_without_type = proc {|d| Gem::Dependency.new(d.name *d.requirement.as_list) }`, which is run 475 times and takes 16ms. [This pull request](https://github.com/bundler/bundler/pull/5354) provides me with the context to know that we want to compare name and requirement, but not necessarily anything else. 

Let's look at the documentation for `Gem::Dependency` to understand how equality works so we don't regress. The entry for comparison shows the following:

> Uses this dependency as a pattern to compare to other. This dependency will match if the name matches the other's name, and other has only an equal version requirement that satisfies this dependency.

As we can see, we simply need to match the name and version requirement to match. This means we don't necessarily need the `Gem::Dependency` as we simply use it for equality. That said `equal version requirement` isn't a particularly easy thing to do.
Requirements such as `1.0.1` and `> 1.0.0` are ok, but are not easily compared. This means we can't do something more naive like compare 2 arrays. Let's look at what the comparison is actually doing.

The comparison is making sure all dependencies match. We could likely do that with individual comparisons, but we'd want to avoid comparing everything if needed (aka bail with false on the first mis-match).
The following block will make sure we have a corresponding entry in `@locked_deps` for all dependencies and that they match.

```ruby
@dependencies.any? do |dependency|
 locked_dep = @locked_deps[dependency.name]
 next true if locked_dep.nil?
 dependency === locked_dep
end
```

This results in the following timings:

```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/definition.rb method: converge_dependencies
   dateFormat  s.SSS

   "(@dependencies + @locked_deps.values).each do |dep|" :a1, 0.000, 0.001
   "locked_source = @locked_deps[dep.name] (run 474 times)" :a1, 0.001, 0.002
   "if Bundler.settings[frozen] && !locked_source.nil? && (run 474 times)" :a1, 0.002, 0.005
   "elsif dep.source (run 474 times)" :a1, 0.005, 0.006
   "dep.source = sources.get(dep.source) (run 142 times)" :a1, 0.006, 0.009
   "if dep.source.is_a?(SourceGemspec) (run 474 times)" :a1, 0.009, 0.010
   "@dependencies.any? do |dependency|" :a1, 0.010, 0.011
   "locked_dep = @locked_deps[dependency.name] (run 9 times)" :a1, 0.011, 0.012
   "next true if locked_dep.nil? (run 9 times)" :a1, 0.012, 0.013
   "dependency === locked_dep (run 9 times)" :a1, 0.013, 0.014
```

As you can see, we've saved about half of the method time.

Running the test added to the [pull request](https://github.com/bundler/bundler/pull/5354) used for context results in a success!

---

Actions
---

- Convert @locked_deps to hash, see if that improves things with `O(1)` access instead. Fixed in [this pull request](https://github.com/bundler/bundler/pull/5539)
- Avoid using `Gem::Dependency` just for comparison in `converge_dependencies`. Fixed in [this pull request](https://github.com/bundler/bundler/pull/5546)
- Can `parse_source` in the lockfile parse be faster? *Not really, this was a dead end*
- Look at caching the evaled gemfile. Not easily possible. There are tons of side effects of the eval which change class level variables. It would require a large refactor for minimal benefit.
- Cache the class instance instead? Uncacheable. Due to extensive use of procs and default values in hashes, we cannot cache the class object.
