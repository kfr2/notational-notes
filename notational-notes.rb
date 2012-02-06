#!/usr/bin/env ruby
# Kevin Richardson <kevin@magically.us>
# https://github.com/kfredrichardson/notational-notes
#
# Converts a directory of notes in text format (like those produced by Notational Velocity/nvAlt)
# into a notes webpage in the style of (url).  Currently supports Markdown formatting syntax.
# Other formatting syntaxes (Textile, etc) should not be particularly difficult to implement.
#
# Optional:  if hide_private is set to true, the script will ignore all files beginning with "private"

require 'rdiscount'

# The location of your NV files.
note_directory   = "/Users/kevin/Dropbox/notational/"
# Where you would like the output files placed.
output_directory = "/Users/kevin/Developer/web/lotusgarden/notes/"
# -- [ Optional ] --
# Ignore files beginning with "private".
hide_private = true
# The name to display in the output's header.
user_name = "Kevin Richardson"
# The URI of your website.
web_uri = "http://kevin.magically.us"

hide_private = false if hide_private.nil?
user_name = "Notational Note User" if user_name.nil?
web_uri = "https://github.com/kfredrichardson/notational-notes" if web_uri.nil?

Dir.chdir(note_directory)
notes_index = File.open(output_directory + "index.htm", "w")
notes_index.puts "<html><head><title>notational notes!</title></head><body><h1><a href='#{web_uri}' title='homepage'>#{user_name}\'s</a> Public Notes!  Enjoy.</h1><hr><ul>"

Dir["*.txt"].each do |file|
    # Ignore files marked as private (if set by user).
    if file =~ /\Aprivate/i
        next if hide_private
    end

    # Convert the note's content to Markdown.
    content  = File.open(file, "r")
    markdown = RDiscount.new(content.read)
    content.close

    # Truncate the ".txt" off the filename.
    file = file.slice(0..-5)

    output = "<html><head><title>#{file}</title></head><body><a href='index.htm'>Notes Home</a><hr>" + markdown.to_html + "</body></html>"

    # Write the note to the output_directory.
    File.new(output_directory + file + ".htm", "w").puts output

    notes_index.puts "<li><a href='#{file}.htm' title='#{file}'>#{file}</a></li>"
end

notes_index.puts "</ul><hr>Powered by <a href='https://github.com/kfredrichardson/notational-notes' title='Notational Notes'>Notational Notes</a></body></html>"
notes_index.close

puts "Done converting notes to HTML."
