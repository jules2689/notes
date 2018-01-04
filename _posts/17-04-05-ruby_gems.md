---
title: RubyGems
date: 2017-04-05T19:24:08-04:00
categories:
- computers
tags:
- computers
- ruby
- bundler
---



## Specification


<!---
```diagram
gantt
   title file: /opt/rubies/2.3.3/lib/ruby/site_ruby/2.3.0/rubygems/specification.rb method: load
   numberFormat  %.2f

   "_spec = LOAD_CACHE[file] (run 296 times)" :a1, 0.000, 0.728
   "return _spec if _spec (run 295 times)" :a1, 0.728, 1.456
   "file = file.dup.untaint (run 295 times)" :a1, 1.456, 2.183
   "return unless File.file?(file) (run 295 times)" :a1, 2.183, 2.911
   "code = if defined? Encoding (run 295 times)" :a1, 2.911, 3.639
   "File.read file  :mode => 'r:UTF-8:-' (run 295 times)" :a1, 3.639, 4.367
   "code.untaint (run 295 times)" :a1, 4.367, 5.095
   "begin (run 295 times)" :a1, 5.095, 5.823
   "_spec = eval code  binding  file (run 295 times)" :a1, 5.823, 97.089
   "if Gem::Specification === _spec (run 295 times)" :a1, 97.089, 97.817
   "_spec.loaded_from = File.expand_path file.to_s (run 295 times)" :a1, 97.817, 98.544
   "LOAD_CACHE[file] = _spec (run 295 times)" :a1, 98.544, 99.272
   "return _spec" :a1, 99.272, 100.000
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/f50cd68abdc716c81b609381352d8c7e.png' alt='diagram image' width='100%'>

