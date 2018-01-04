---
title: Auto-generating Gantt charts for a method
date: 2017-04-05T19:24:08-04:00
categories:
- computers
tags:
- computers
- ruby
---



While working on timing the performance of Bundler, I noticed that Gantt charts are an effective way to visualize slowness. Working off of this theory, I automated the generation of the charts using [Mermaid](http://knsv.github.io/mermaid/index.html). The resulting chart data can be plugged into [this online editor](http://knsv.github.io/mermaid/live_editor/), or you can generate it using the Mermaid library yourself.

```ruby
 # We use a global aggregate cache to allow us to track methods within a loop all at once
$timed = {}
at_exit do
  $timed.each do |method_name, timed_hash|
    # Output mermaid syntax for gantt
    title_file = timed_hash[:path].gsub(ENV['GEM_HOME'], '').gsub(ENV['HOME'], '')
    puts "gantt"
    puts "   title file: #{title_file} method: #{method_name}"
    puts "   dateFormat  s.SSS\n\n"

    curr_time = 0.000

    # Aggregate the lines together. Loops can cause things to become unweildly otherwise
    @grouped_lines = timed_hash[:entries].group_by { |line| [line[:line], line[:line_no]] }

    @grouped_lines.each do |(group_name, _line_no), group|
      # If we have run more than once, we should indicate how many times something is called
      entry_name = group.size > 1 ? "#{group_name} (run #{group.size} times)" : group_name
      entry_name = entry_name.tr('"', "'").tr(",", ' ') # Mermaid has trouble with these

      # Total time for all entries to run
      total_time = group.collect { |e| e[:time] }.inject(:+)
      time = total_time < 0.001 ? 0.001 : total_time

      # Output the line
      post_time = time + curr_time
      puts format("   \"#{entry_name}\" :a1, %.3f, %.3f", curr_time, post_time)
      curr_time = post_time
    end

    puts "\n\n"
  end
end

def gantt_chart
  ret = nil

  # Determine the method and path that we're calling from
  call_loc = caller_locations.reject { |l| l.path.include?('byebug') }.first
  method_name = call_loc.label
  path = call_loc.path
  source = File.readlines(path)

  unless $timed[method_name]
    puts "Tracing #{path} for method #{method_name}"
    $timed[method_name] = { path: path, entries: [] }
  end

  # This block will be used to finalize the time it to run, gather the line source, etc.
  finalize_time = -> () do
    if last = $timed[method_name][:entries].pop
      # Finalize the time
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - last[:start]
      # Get the source line from the line number
      line = source[last[:line_no] - 1].strip
      $timed[method_name][:entries] << { line_no: last[:line_no], line: line, time: time }
    end
  end

  # We use Ruby's tracepoint on a per line basis
  # We only care about lines called within our method and within our path
  TracePoint.new(:line) do |tp|
    next unless tp.path == path
    next unless tp.method_id.to_s == method_name.to_s

    # We could have a call from last time, finalize it, we've moved to a new line
    finalize_time.call
    # Initialize a new entry with the line number and a start time
    $timed[method_name][:entries] << { line_no: tp.lineno, start: Process.clock_gettime(Process::CLOCK_MONOTONIC) }
  end.enable do
    ret = yield
    finalize_time.call # The last call needs to be finalized, finalize it here
  end
  
  ret
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
