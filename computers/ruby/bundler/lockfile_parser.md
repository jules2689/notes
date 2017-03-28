# bundler/lockfile_parser.rb



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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/2815979f5faca9ffb7d6b284db8d7dc5.png' alt='diagram image' width='100%'>


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
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/b23337a3a983b311ac0d2c34e6f2663d.png' alt='diagram image' width='100%'>

