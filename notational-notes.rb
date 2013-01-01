#!/usr/bin/env ruby
# Kevin Richardson <kevin@magically.us>
# https://github.com/kfr2/notational-notes
#
# Converts a directory of notes in text format (like those produced by Notational Velocity/nvAlt)
# into a notes webpage in the style of http://bit.ly/YM0giJ.  Currently supports Markdown formatting syntax.
# Other formatting syntaxes (Textile, etc) should not be particularly difficult to implement.
#
# Optional:  if hide_private is set to true, the script will ignore all files beginning with "private"

require 'rdiscount'

# -- [ Optional ] --
# Ignore files beginning with "private".
hide_private = true
# The name to display in the output's header.
user_name = "Kevin Richardson"
# The URI of your website.
web_uri = "http://magically.us"
# The name for your notes.
notes_name = 'Notes'

if ARGV.count < 2 
    puts "Usage: #{__FILE__} INPUT_DIR OUTPUT_DIR"
    Kernel.exit
end

note_directory = ARGV[0]
output_directory = ARGV[1]
hide_private = false if hide_private.nil?
user_name = "Notational Note User" if user_name.nil?
web_uri = "https://github.com/kfr2/notational-notes" if web_uri.nil?
notes_name = 'Notes' if notes_name.nil?

template = ''
f = File.open('template.htm', 'r')
f.each_line do |line|
    template += line
end
template.gsub!('{{user_name}}', user_name)
template.sub!('{{web_uri}}', web_uri)
template.sub!('{{notes_name}}', notes_name)
template.sub!('{{notes_name}}', notes_name)

notes_list = []


# Holds the latest update time for display in the index file.
newest_time = Time.new(0)

Dir.chdir(note_directory)
Dir["*.txt"].each do |file|
    # Ignore files marked as private (if set by user).
    if file =~ /\Aprivate/i
        next if hide_private
    end

    note_template = String.new(template)

    # Convert the note's content to Markdown if necessary.
    content  = File.open(file, "r")
    modified = content.mtime 
    newest_time = modified if modified > newest_time
    markdown = RDiscount.new(content.read)
    content.close

    # Truncate the ".txt" off the filename.
    file = file.slice(0..-5)

    notes_list.push file

    note_template.sub!('{{note_uri}}', "#{file}.htm")
    note_template.sub!('{{note_name}}', file)
    note_template.sub!('{{content}}', markdown.to_html)
    note_template.sub!('{{last_modified}}', modified.to_s)

    File.new(output_directory + "#{file}.htm", "w").puts note_template
end

template.sub!('{{note_name}}', notes_name)
template.sub!('{{note_uri}}', 'index.htm')
content = '<ul>'
notes_list.each do |note|
    content += "<li><a href='#{note}.htm' title='#{note}'>#{note}</a></li>"
end
content += '</ul>'
template.sub!('{{content}}', content)

notes_index = File.open(output_directory + "index.htm", "w")
notes_index.puts template.sub('{{last_modified}}', newest_time.to_s)
notes_index.close

puts "Done converting notes to HTML."
