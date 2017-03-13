#!/usr/bin/env ruby

require 'json'
require 'htmlbeautifier'

IGNORED_DIRS = %w(assets bin public)
ALLOWED_EXTS = %w(.md .html .pdf)

def directory_hash(path, name=nil)
  data = {:data => (name || path)}
  data[:children] = children = []
  Dir.foreach(path) do |entry|
    # Skip Hidden Files
    next if entry.start_with?('.') || entry.start_with?('_')
    # Skip files unless they are a directory or a file with an allowed extension
    next if !ALLOWED_EXTS.include?(File.extname(entry)) && !File.directory?(File.join(path, entry))
    # Skip ignored directories
    next if IGNORED_DIRS.include?(entry)

    # Actually parse the children list recursively
    full_path = File.join(path, entry)
    if File.directory?(full_path)
      if h = directory_hash(full_path, entry)
        children << h
      end
    else
      children << entry
    end
  end
  data
end

def to_toc(toc_array, sidebar = false, prefix = '')
  list = []
  toc_array.each do |entry|
    if entry.is_a?(Hash)
      next if entry[:children].empty?
      sub_toc = to_toc(entry[:children], sidebar, File.join(prefix,entry[:data]))
      list << "<li>#{section_title(entry, prefix)}#{sub_toc}</li>"
    else
      entry_wo_ext = if File.extname(entry) == '.html' || File.extname(entry) == '.md'
        entry.split('.')[0..-2].join('.')
      else
        entry
      end
      next if entry_wo_ext == 'index' || entry_wo_ext == 'README'
      list << "<li><a href='#{File.join(prefix, entry_wo_ext)[1..-1]}'>#{humanize(entry_wo_ext)}</a></li>"
    end
  end
  "<ul class='#{sidebar ? 'sidebar-nav-item' : ''}'>" + list.join + "</ul>"
end

def section_title(entry, prefix)
  if entry[:children].include?('README.md') || entry[:children].include?('index.html')
    href = File.join(prefix, entry[:data])[1..-1]
    "<p><a href='#{href}'>#{humanize(entry[:data])}</a></p>"
  else
    "<p>#{humanize(entry[:data])}</p>"
  end
end

def humanize(word)
  result = word.to_s.dup
  result.sub!(/\A_+/, ''.freeze)
  result.sub!(/_id\z/, ''.freeze)
  result.tr!('_'.freeze, ' '.freeze)
  result.gsub!(/\s\w/) { |match| match.upcase }
  result.sub!(/\A\w/) { |match| match.upcase }
  result
end

path = File.expand_path('../../', __FILE__)
toc_hash = directory_hash(path)

# Main TOC
html = to_toc(toc_hash[:children], false) 
beautiful = HtmlBeautifier.beautify(html)
path = File.expand_path('../../_includes/toc.html', __FILE__)
File.write(path, beautiful)

# Sidebar TOC
html = to_toc(toc_hash[:children], true) 
beautiful = HtmlBeautifier.beautify(html)
path = File.expand_path('../../_includes/sidebar_toc.html', __FILE__)
File.write(path, beautiful)
