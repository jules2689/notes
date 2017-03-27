# bundler/definition.rb


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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/23b676377c99e839cbedb08ef02c2580.png' alt='diagram image' height='400px'>


As we can see, `Definition.build` take a long time to process.

---

## Definition.build


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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/8e82477f959f767a7fd4cf8c58b1f5fb.png' alt='diagram image' height='400px'>



From here we can see `Dsl.evaluate` takes the most time

---

## Dsl.evaluate


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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/9a323efe751f19d3f0e6b0a4664dcc77.png' alt='diagram image' height='400px'>



We can see that the time is split between `eval_gemfile` and `to_definition`.

---

## builder.eval_gemfile


<!---
```diagram
gantt
   title lib/bundler/dsl.rb#eval_gemfile
   dateFormat  s.SSS

   begin :a1, 0.000, 0.001
   expanded_gemfile_path = Pathname.new(gemfile).expand_path :a1, 0.001, 0.002
   original_gemfile = @gemfile :a1, 0.002, 0.003
   @gemfile = expanded_gemfile_path :a1, 0.003, 0.004
   contents ||= Bundler.read_file(gemfile.to_s) :a1, 0.004, 0.005
   instance_eval(contents.dup.untaint, gemfile.to_s, 1) :a1, 0.005, 0.058
   @gemfile = original_gemfile :a1, 0.058, 0.059
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/f094577994ddf6eaf7d8fd4830e314af.png' alt='diagram image' height='400px'>



We can see here that when we take the contents of the bundler file, and `instance_eval` it, we'll spend about 55ms doing that.
Without a refactor, we likely cannot get away from this.

---

## builder.to_definition

This method simply calls `Definition.new`, so we'll move to that instead.

---

### Definition.new


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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/b09f829c9ab8241be0bf624e1fccb56e.png' alt='diagram image' height='1000px'>



Some lines that pop out are as follows:

| line | time |
| -- | -- |
| `@locked_gems = LockfileParser.new(@lockfile_contents) :a1, 0.014, 0.062` | 48 ms |
| `converge_path_sources_to_gemspec_sources :a1, 0.076, 0.094` | 18 ms |
| `@source_changes = converge_sources :a1, 0.095, 0.109` | 14 ms |
| `@dependency_changes = converge_dependencies :a1, 0.113, 0.181` | 68 ms |
| `fixup_dependency_types! :a1, 0.183, 0.194` | 11 ms |

---

#### LockfileParser.new

See [lockfile_parser](../lockfile_parser)

---

#### definition#coverge_dependencies


<!---
```diagram
gantt
   title bundler/definition.rb#converge_dependencies
   dateFormat  s.SSS

   "(@dependencies + @locked_deps).each do |dep|" :a1, 0.000, 0.001
   "locked_source = @locked_deps.select {|d| d.name == dep.name }.last (run 112812 times)" :a1, 0.001, 0.186
   "if Bundler.settings[:frozen] && !locked_source.nil? && (run 474 times)" :a1, 0.186, 0.191
   "elsif dep.source (run 474 times)" :a1, 0.191, 0.192
   "dep.source = sources.get(dep.source) (run 142 times)" :a1, 0.192, 0.197
   "if dep.source.is_a?(Source::Gemspec) (run 474 times)" :a1, 0.197, 0.198
   "dependency_without_type = proc {|d| Gem::Dependency.new(d.name *d.requirement.as_list) } (run 475 times)" :a1, 0.198, 0.214
   "Set.new(@dependencies.map(&dependency_without_type)) != Set.new(@locked_deps.map(&dependency_without_type))" :a1, 0.214, 0.215
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/6e16e312d0841cc8d91df0ed7768669a.png' alt='diagram image' height='500px'>


It is very obvious to see that this particular line `locked_source = @locked_deps.select {|d| d.name == dep.name }.last (run 112812 times) :a1, 0.001, 0.182` is the root cause of the slowness.
Run 112-113K times for the Shopify application, it is slow and could likely benefit from some up front hashing.
