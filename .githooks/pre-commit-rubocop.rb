#!/usr/bin/env ruby

# frozen_string_literal: true

ADDED_OR_MODIFIED = /^\s*(A|AM|M)/

changed_files = `git status --porcelain`.split(/\n/)
unstaged_files = `git ls-files -m`.split(/\n/)

changed_files = changed_files.select { |f| f =~ ADDED_OR_MODIFIED }
changed_files = changed_files.map { |f| f.split(" ")[1..-1].join(' ') }

changed_files -= (unstaged_files - changed_files)

changed_files = changed_files.select do |file_name|
  File.extname(file_name) == ".rb" || File.extname(file_name) == ".rake"
end

changed_files = changed_files.join(" ")

exit(0) if changed_files.empty?

success = system(%(
  rubocop #{changed_files}
))

STDIN.reopen('/dev/tty')

if success == false
  puts
  puts 'Rubocop returned warnings.  Would you like to commit anyway?'
  puts '(y or yes to ignore warnings) '
  exit(1) unless %w[y yes].include? gets.chomp.downcase
end
