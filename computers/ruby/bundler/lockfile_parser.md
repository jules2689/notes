# bundler/lockfile_parser.rb

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

Here, we see that `parse_#{@state}` is the bulk of the work. This is a dynamic call to parse methods... is any one of them slower than another?
