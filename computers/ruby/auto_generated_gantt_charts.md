# Auto-generating Gantt charts for a method

While working on timing the performance of Bundler, I noticed that Gantt charts are an effective way to visualize slowness. Working off of this theory, I automated the generation of the charts using [Mermaid](http://knsv.github.io/mermaid/index.html).

```ruby
 def gantt_chart
  # Determine the method and path that we're calling from
  call_loc = caller_locations.reject { |l| l.path.include?('byebug') }.first
  method_name = call_loc.label
  path = call_loc.path
  source = File.readlines(path)

  puts "Tracing #{path} for method #{method_name}"

  @timed = []

  # This block will be used to finalize the time it to run, gather the line source, etc.
  finalize_time = -> () do
    if last = @timed.pop
      # Finalize the time
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - last[:start] 
      # Get the source line from the line number
      line = source[last[:line_no] - 1].strip
      @timed << { line_no: last[:line_no], line: line, time: time }
    end
  end

  # We use Ruby's tracepoint on a per line basis
  # We only care about lines called within our method and within our path
  trace = TracePoint.new(:line) do |tp|
    next unless tp.path == path
    next unless tp.method_id.to_s == method_name.to_s

    # We could have a call from last time, finalize it, we've moved to a new line
    finalize_time.call
    # Initialize a new entry with the line number and a start time
    @timed << { line_no: tp.lineno, start: Process.clock_gettime(Process::CLOCK_MONOTONIC) }
  end

  begin
    trace.enable
    yield
  ensure
    # At this point we are done the method, but one more time needs to be finalized
    finalize_time.call
    trace.disable
  end

  # Output mermaid syntax for gantt
  puts "gantt"
  puts "   title file: #{path} method: #{method_name}"
  puts "   dateFormat  s.SSS\n\n"

  @timed.each_with_object(0.000) do |timed_line, curr_time|
    time = timed_line[:time] < 0.001 ? 0.001 : timed_line[:time]
    post_time = time + curr_time
    puts "   #{timed_line[:line]} :a1, #{"%.3f" % curr_time}, #{"%.3f" % post_time}"
    curr_time = post_time
  end

  puts "\n\n"
end
```

## Usage

Running this on `Bundler`'s `lib/bundler.rb`'s `setup` method, we get this source code:

```ruby
def setup(*groups)
  gantt_chart do
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
  end
end
```

and this chart:


<!---
```diagram
gantt
   title file: /Users/juliannadeau/.gem/ruby/2.3.3/gems/bundler-1.14.5/lib/bundler.rb method: setup
   dateFormat   s.SSS

   return @setup if defined?(@setup) && @setup :a1, 0.000, 0.001
   definition.validate_runtime! :a1, 0.001, 0.229
   SharedHelpers.print_major_deprecations! :a1, 0.229, 0.230
   if groups.empty? :a1, 0.230, 0.231
   @setup = load.setup :a1, 0.231, 1.312
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/bundler_setup.png' alt='diagram image' width='100%'>


We can now dig deeper into the lines `definition.validate_runtime!` and `@setup = load.setup` as they take the most time.
