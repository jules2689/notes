#!/usr/bin/env ruby

require 'fileutils'
require 'time'

files = if ARGV.empty?
  FileUtils.rm_rf(Dir.glob("jekyll/_posts/*"))
  Dir.glob('**/*.md').reject{ |f| f['jekyll'] || f['vendor'] || File.basename(f) == "README.md" }
else
  [ARGV].flatten
end

files.each do |file|
  puts "Processing #{file}"

  create_time = DateTime.parse(`git log --format=%aD #{file} | tail -1`)
  puts "-> #{create_time}"

  content = File.read(file)
  title = if mat = content.match(/^# (.*)$/)
    mat[1].strip
  else
    File.basename(file, '.md')
  end
  tags = File.dirname(file).split('/').reject { |t| t == "." }
  tags = ["default"] if tags.empty?
    puts "-> #{tags.join(', ')}"

  template = <<-EOF
---
title: #{title}
date: #{create_time}
categories:
- #{tags.first}
tags:
- #{tags.join("\n- ")}
---
  EOF

  File.write(
    "jekyll/_posts/#{create_time.strftime("%y-%m-%d")}-#{File.basename(file)}",
    template + "\n" + content.gsub(/^# (.*)$/, '')
  )
end
