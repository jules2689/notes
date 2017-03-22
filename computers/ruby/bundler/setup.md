# bundler/setup

Bundler setup parses through dependencies and compiles them into proper load paths. This step, on smaller applications, takes very little time. However on larger applications, this step can take a long duration - about 700-750ms to be exact.

Below are notes about how long certain parts take.

## Highest Level

If we open the `bundler/setup.rb` file up, we might notice that it is small enough to simply benchmark each line. Doing this results in the following sequence diagram:


<!---
```diagram
gantt
    title require 'bundler/setup'
    dateFormat  s.SSS

    section require
    bundler/postit_trampoline :a1, 0.000, 0.006
    bundler/shared_helpers :a1, 0.006, 0.007
    bundler :a1, 0.007, 0.010

    section Bundler
    Bundler.setup :a2, 0.010, 0.710

    section various
    "other" :a3, 0.710, 0.711
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/ab3cdf34c521c668b44359644dcd6d8f.png' alt='diagram image' height='400px'>


We can take note that `Bundler.setup` results in almost the entire duration of the call to `require 'bundler/setup'`. Let's dig into that more.

## `Bundler.setup`

The call to `Bundler.setup` is a little bit ambiguous due to parameters, but checking the `source_location` at runtime results in `setup` at line 90 of `lib/bundler.rb`.
This was what I originally thought, but it it good to check.

```ruby
$ Bundler.method(:setup).source_location
["/Users/juliannadeau/.gem/ruby/2.3.3/gems/bundler-1.14.5/lib/bundler.rb", 90]
```

The method definition here is as follows:
```ruby
# Return if all groups are already loaded
return @setup if defined?(@setup) && @setup

definition.validate_runtime!

SharedHelpers.print_major_deprecations!

if groups.empty?
  # Load all groups, but only once
  @setup = load.setup
else
  load.setup(*groups)
end
```

We can see that it caches the orginal result on the `Bundler` class and so we can only call it once per run. This is good as it will save a lot of time if we happen to call it twice.

A few questions I have up front:

- is `definition` a variable or a method? Given that this is the first call to a class, it's probably a method.
- `groups` is almost definitely empty. It is probably a method too. Is it cached?
- same thing with `load`

The reason this is important is that while the method calls on the return values of the methods mentioned above should be traced, we need to make sure that the method calls to get those return values
aren't slow either. To do this, we will need to split up the variable/method calls.

We end up with this:

```ruby
# Return if all groups are already loaded
return @setup if defined?(@setup) && @setup

d = _t('definition') do
  definition
end

_t('validate_runtime!') do
  d.validate_runtime!
end

_t('print_major_deprecations') do
  SharedHelpers.print_major_deprecations!
end

g = _t('groups') do
  groups
end

l = _t('load') do
  load
end

if g.empty?
  # Load all groups, but only once
  @setup = _t('setup 1') do
    l.setup
  end
else
  _t('setup 2') { l.setup(*groups) }
end
```

### Timing Helper

Note: `_t` is a timing helper for scrappy timing defined as such

```ruby
    def _t(label)
      t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      ret = yield
      puts "#{label} #{Process.clock_gettime(Process::CLOCK_MONOTONIC) - t}"
      ret
    end
```

The key thing to note is that it uses CPU time and the return value is whatever it is from the yield. The latter point makes it easy to track things down.

### Results of timing


<!---
```diagram
gantt
    title Bundler.setup
    dateFormat  s.SSS

    section description
    initialize :a1, 0.000, 0.129
    description.validate_runtime! :a1, 0.129, 0.130

    section SharedHelpers
    print_major_deprecations! :a2, 0.130, 0.131

    section groups
    groups :a3, 0.131, 0.132

    section load
    load :a4, 0.132, 0.133
    load.setup :a4, 0.133, 0.683
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/75890057a20de01f006baac5a4c816ab.png' alt='diagram image' height='400px'>

