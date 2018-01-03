#!/usr/bin/env ruby

require 'fileutils'
require 'time'

FileUtils.rm_rf(Dir.glob("jekyll/_posts/*"))

files = Dir.glob('**/*.md').reject{ |f| f['jekyll'] || File.basename(f) == "README.md" }

files.each do |file|
  create_time = DateTime.parse(`git log --format=%aD #{file} | tail -1`)

  content = File.read(file)
  title = if mat = content.match(/^# (.*)$/)
    mat[1].strip
  else
    File.basename(file, '.md')
  end
  tags = File.dirname(file).split('/').reject { |t| t == "." }
  tags = ["default"] if tags.empty?

  template = <<-EOF
---
title: #{title}
date: #{create_time}
categories:
- #{tags.join("\n- ")}
tags:
- #{tags.join("\n- ")}
---
  EOF

  File.write(
    "jekyll/_posts/#{create_time.strftime("%y-%m-%d")}-#{File.basename(file)}",
    template + "\n" + content.gsub(/^# (.*)$/, '')
  )
end
