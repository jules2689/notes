#!/usr/bin/env ruby

require 'listen'

listener = Listen.to('.', only: /\.md$/, ignore: [%r{jekyll/}], relative: true) do |modified, added, removed|
  changes = (modified + added + removed)
  system("bin/build.rb #{changes.join(' ')}")
end
listener.start # not blocking
sleep
