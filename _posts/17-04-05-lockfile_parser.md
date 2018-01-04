---
title: bundler/lockfile_parser.rb
date: 2017-04-05T19:24:08-04:00
categories:
- computers
tags:
- computers
- ruby
- bundler
---



<!---
```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/lockfile_parser.rb method: initialize
   dateFormat  s.SSS

   "@platforms    = []" :a1, 0.000, 0.001
   "@sources      = []" :a1, 0.001, 0.002
   "@dependencies = []" :a1, 0.002, 0.003
   "@state        = nil" :a1, 0.003, 0.004
   "@specs        = {}" :a1, 0.004, 0.005
   "@rubygems_aggregate = Source::Rubygems.new" :a1, 0.005, 0.006
   "if lockfile.match(/<<<<<<<|=======|>>>>>>>|\|\|\|\|\|\|\|/)" :a1, 0.006, 0.007
   "lockfile.split(/(?:\r?\n)+/).each do |line|" :a1, 0.007, 0.008
   "if SOURCE.include?(line) (run 1445 times)" :a1, 0.008, 0.010
   "@state = :source (run 72 times)" :a1, 0.010, 0.011
   "parse_source(line) (run 72 times)" :a1, 0.011, 0.012
   "elsif line == DEPENDENCIES (run 1373 times)" :a1, 0.012, 0.014
   "elsif line == PLATFORMS (run 1372 times)" :a1, 0.014, 0.016
   "elsif line == RUBY (run 1371 times)" :a1, 0.016, 0.018
   "elsif line == BUNDLED (run 1371 times)" :a1, 0.018, 0.020
   "elsif line =~ /^[^\s]/ (run 1370 times)" :a1, 0.020, 0.025
   "elsif @state (run 1370 times)" :a1, 0.025, 0.027
   "send('parse_{@state}', line) (run 1370 times)" :a1, 0.027, 0.077
   "@state = :platform" :a1, 0.077, 0.078
   "@state = :dependency" :a1, 0.078, 0.079
   "@state = :bundled_with" :a1, 0.079, 0.080
   "@sources << @rubygems_aggregate" :a1, 0.080, 0.081
   "@specs = @specs.values.sort_by(&:identifier)" :a1, 0.081, 0.090
   "warn_for_outdated_bundler_version" :a1, 0.090, 0.091
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/Screen Shot 2017-03-28 at 4.50.46 PM.png' alt='diagram image' width='100%'>

Here, we see that `parse_#{@state}` is the bulk of the work. This is a dynamic call to parse methods... is any one of them slower than another?

To solve this, I split out the dynamic line into a case statement to see which lines were being called.

```diff
elseif @state
+ case @state.to_s
+ when 'source'
+     parse_source(line)
+ when 'dependency'
+     parse_dependency(line)
+ when 'spec'
+     parse_spec(line)
+ when 'platform'
+     parse_platform(line)
+ when 'bundled_with'
+     parse_bundled_with(line)
+ when 'ruby'
+     parse_ruby(line)
+ else
+     send("parse_#{@state}", line)
+ end
- send("parse_#{@state}", line)   
end
```

By the diagram below, we can see the following from our case statement:

| parse_state | number | time |
| --- | --- | --- |
| parse_source | 1131 times | 32ms | `SOURCE` did not include line, so it went to the case statement | 
| parse_platform | 1 time | 1 ms | - |
| parse_dependency | 237 times | 15 ms | - |
| parse_bundled_with | 1 time | 1 ms | - |

<!---
```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/lockfile_parser.rb method: initialize
   dateFormat  s.SSS

   "@platforms    = []" :a1, 0.000, 0.001
   "@sources      = []" :a1, 0.001, 0.002
   "@dependencies = []" :a1, 0.002, 0.003
   "@state        = nil" :a1, 0.003, 0.004
   "@specs        = {}" :a1, 0.004, 0.005
   "@rubygems_aggregate = Source::Rubygems.new" :a1, 0.005, 0.006
   "if lockfile.match(/<<<<<<<|=======|>>>>>>>|\|\|\|\|\|\|\|/)" :a1, 0.006, 0.007
   "lockfile.split(/(?:\r?\n)+/).each do |line|" :a1, 0.007, 0.008
   "if SOURCE.include?(line) (run 1445 times)" :a1, 0.008, 0.012
   "@state = :source (run 72 times)" :a1, 0.012, 0.013
   "parse_source(line) (run 72 times)" :a1, 0.013, 0.014
   "elsif line == DEPENDENCIES (run 1373 times)" :a1, 0.014, 0.015
   "elsif line == PLATFORMS (run 1372 times)" :a1, 0.015, 0.017
   "elsif line == RUBY (run 1371 times)" :a1, 0.017, 0.019
   "elsif line == BUNDLED (run 1371 times)" :a1, 0.019, 0.021
   "elsif line =~ /^[^\s]/ (run 1370 times)" :a1, 0.021, 0.024
   "elsif @state (run 1370 times)" :a1, 0.024, 0.026
   "case @state.to_s (run 1370 times)" :a1, 0.026, 0.029
   "parse_source(line) (run 1131 times)" :a1, 0.029, 0.061
   "@state = :platform" :a1, 0.061, 0.062
   "parse_platform(line)" :a1, 0.062, 0.063
   "@state = :dependency" :a1, 0.063, 0.064
   "parse_dependency(line) (run 237 times)" :a1, 0.064, 0.079
   "@state = :bundled_with" :a1, 0.079, 0.080
   "parse_bundled_with(line)" :a1, 0.080, 0.081
   "@sources << @rubygems_aggregate" :a1, 0.081, 0.082
   "@specs = @specs.values.sort_by(&:identifier)" :a1, 0.082, 0.093
   "warn_for_outdated_bundler_version" :a1, 0.093, 0.094
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/Screen Shot 2017-03-28 at 4.46.45 PM.png' alt='diagram image' width='100%'>

---

parse_source
---

<!---
```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/lockfile_parser.rb method: parse_source
   dateFormat  s.SSS

   "case line (run 1203 times)" :a1, 0.000, 0.003
   "@current_source = nil (run 72 times)" :a1, 0.003, 0.004
   "@opts = {} (run 72 times)" :a1, 0.004, 0.005
   "@type = line (run 72 times)" :a1, 0.005, 0.006
   "value = $2 (run 205 times)" :a1, 0.006, 0.007
   "value = true if value == 'true' (run 205 times)" :a1, 0.007, 0.008
   "value = false if value == 'false' (run 205 times)" :a1, 0.008, 0.009
   "key = $1 (run 205 times)" :a1, 0.009, 0.010
   "if @opts[key] (run 205 times)" :a1, 0.010, 0.011
   "@opts[key] = value (run 205 times)" :a1, 0.011, 0.014
   "case @type (run 72 times)" :a1, 0.014, 0.015
   "@current_source = TYPES[@type].from_lock(@opts) (run 71 times)" :a1, 0.015, 0.016
   "if @sources.include?(@current_source) (run 71 times)" :a1, 0.016, 0.017
   "@sources << @current_source (run 71 times)" :a1, 0.017, 0.018
   "parse_spec(line) (run 854 times)" :a1, 0.018, 0.057
   "Array(@opts['remote']).each do |url|" :a1, 0.057, 0.058
   "@rubygems_aggregate.add_remote(url)" :a1, 0.058, 0.059
   "@current_source = @rubygems_aggregate" :a1, 0.059, 0.060
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/Screen Shot 2017-03-28 at 4.47.00 PM.png' alt='diagram image' width='100%'>

`parse_spec` is the obvious bulk of this method, so let's also look there.

---

parse_spec
---

The parse spec code looks like so:

```ruby
def parse_spec(line)
  if line =~ NAME_VERSION_4
    name = $1
    version = $2
    platform = $3
    version = Gem::Version.new(version)
    platform = platform ? Gem::Platform.new(platform) : Gem::Platform::RUBY
    @current_spec = LazySpecification.new(name, version, platform)
    @current_spec.source = @current_source

    # Avoid introducing multiple copies of the same spec (caused by
    # duplicate GIT sections)
    @specs[@current_spec.identifier] ||= @current_spec
  elsif line =~ NAME_VERSION_6
    name = $1
    version = $2
    version = version.split(",").map(&:strip) if version
    dep = Gem::Dependency.new(name, version)
    @current_spec.dependencies << dep
  end
end
```

It takes about 15-17ms to run all of it. I'd like to see how often each part is called.

- NAME_VERSION_4, called 374 times, took about 7ms
- NAME_VERSION_6, called 480 times, took about 8ms

Which means they take equally as long, but the NAME_VERSION_4 option is slower taking about 0.000044s for each run as opposed to 0.000035s for each run.

So, what is the difference between these two? Well NAME_VERSION_4 is a top level dependency, whereas NAME_VERSION_6 is a sub-dependency, it seems.

```ruby
 NAME VERSION 4     web-console (3.4.0)
 NAME VERSION 6       actionview (>= 5.0)
 NAME VERSION 6       activemodel (>= 5.0)
 NAME VERSION 6       debug_inspector
 NAME VERSION 6       railties (>= 5.0)
 NAME VERSION 4     webmock (2.3.2)
 NAME VERSION 6       addressable (>= 2.3.6)
 NAME VERSION 6       crack (>= 0.3.2)
 NAME VERSION 6       hashdiff
```

So what does this actually do? Seems it resolves specifications from the lockfile. The "4 space" (NAME VERSION 4) seems to also load a current spec, which I don't quite get. Seems we re-assign this class level variable a lot to avoid passing it around.

<!--
```diagram
gantt
   title file: /gems/bundler-1.14.6/lib/bundler/lockfile_parser.rb method: parse_spec
   dateFormat  s.SSS

   "if line =~ NAME_VERSION_4 (run 854 times)" :a1, 0.000, 0.004
   "name = $1 (run 374 times)" :a1, 0.004, 0.005
   "version = $2 (run 374 times)" :a1, 0.005, 0.006
   "platform = $3 (run 374 times)" :a1, 0.006, 0.007
   "version = Gem::Version.new(version) (run 374 times)" :a1, 0.007, 0.009
   "platform = platform ? Gem::Platform.new(platform) : Gem::Platform::RUBY (run 374 times)" :a1, 0.009, 0.010
   "@current_spec = LazySpecification.new(name  version  platform) (run 374 times)" :a1, 0.010, 0.013
   "@current_spec.source = @current_source (run 374 times)" :a1, 0.013, 0.014
   "elsif line =~ NAME_VERSION_6 (run 480 times)" :a1, 0.014, 0.016
   "name = $1 (run 480 times)" :a1, 0.016, 0.018
   "version = $2 (run 480 times)" :a1, 0.018, 0.019
   "version = version.split(' ').map(&:strip) if version (run 480 times)" :a1, 0.019, 0.021
   "dep = Gem::Dependency.new(name  version) (run 480 times)" :a1, 0.021, 0.035
   "@specs[@current_spec.identifier] ||= @current_spec" :a1, 0.035, 0.036
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/Screen Shot 2017-03-28 at 6.33.13 PM.png' alt='diagram image' width='100%'>

We can see that `"dep = GemDependency.new(name  version) (run 480 times)" :a1, 0.021, 0.035` takes a chunk of time (14ms with gantt generation, 6ms in reality), otherwise there's not much bulk here.

---

So, in the end the reason this file is slower is that it is iterating over many sources and creating `Gem::Dependency` objects. There is likely something we could do to make `LockFileParser` faster, but the work likely won't be worth the time spent.

There isn't much we can do to make this file faster without caching using marshalling the data or something.
