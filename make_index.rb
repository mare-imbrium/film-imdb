#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: make_index.rb
#  Description: This creates in index to look up actor or actress file by byteoffset.
#  It ignores intro portion and then takes byte offset of every line that starts with A-Z.
#  This is printed to another file. Use `look` for an actors name and get the byteoffset.
#  Then use readbyte.rb to read from that offset to next blank line.
#
#  OUTDATE description.
#  Generates an index file that has first char and lineno
#     so when we are searching for an actor, take first char, and see which range it is in.
#     Today the actor file contains a name for each alphabet, but what if alphabet does not exist.
#     Then search will take full file.
#     Typically we will extract range as :
#        grep -A 1 "^T" idx.file | cut -f2 -d:
#     and then cut the two lineno's
#       Or read file into an array or Hash, seek first char and then take next offset.
#
#     The faster usage is to use `look` to get the start offset
#     and seek that offset and read till the next newline. 
#     readbyte.rb does that given a filename and offset.
#
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-17 - 12:17
#      License: MIT
#  Last update: 2015-11-21 10:54
# ----------------------------------------------------------------------------- #
#  make_index.rb  Copyright (C) 2012-2014 j kepler
# ----------------------------------------------------------------------------- #

def pindex ofile, chars, lineno, pos
  ofile.printf("%s\t%d\n", chars, pos)
  if !$verbose
    #printf("%s:%s\n", chars, pos) 
    printf( "==== (%s => %d)\r", chars[0,2], pos)
  end
end

def run filename
  wid = 0 # width of index
  #myhash = Hash.new;
  file = File.new(filename, "r");
  #ofilename = "idx.#{wid}."+filename ;
  ofilename = filename + ".#{wid}.idx";
  pinfo "Writing index to #{ofilename} "
  ofile = File.new(ofilename, "w");
  firstline=file.readline;
  pdone firstline;
  lineno = 1

  pos = 0
  if firstline.index("CRC") == 0
    # this file contains intro. we need to skip
    pinfo "contains intro we need to skip "
    while (line = file.gets)
      lineno += 1
      if line.index("----\t\t\t") == 0
        puts
        pdone "Found data start."
        break
      else
        print "."
      end
    end
  else
    file.pos = 0
    # if first line was actual data then we have already read it. 
    # We will read again in next loop and lose it.
    # We need to close and open, or read at end of next loop.
  end
  pinfo "Starting index ... will take a minute or two ..."
  #firstline=file.readline;
  #pdone firstline
  pos = file.tell
  while (line = file.gets)
    lineno += 1
    line = line.chomp
    #next if line == ""
    #next if line =~ /^$/
    #next if line[0] == "\t"
    #if line =~ /^\-\-\-\-/
      #perror "\nDetected hyphens in line #{lineno} ... skipping\n"
      #next
    #end
    if line.index("SUBMITTING") == 0
      pdone "\nDetected end of data and start of end section"
      break
    end
    if line[0] =~ /[A-Z]/
      words = line.split("\t")
      pindex ofile, words.first, lineno, pos
    end
    pos = file.tell
  end
  file.close
  ofile.close
  puts
  pdone "Operation over!"

end

$verbose = false
$debug = false
CLEAR      = "\e[0m"
BOLD       = "\e[1m"
BOLD_OFF       = "\e[22m"
RED        = "\e[31m"
ON_RED        = "\e[41m"
GREEN      = "\e[32m"
YELLOW     = "\e[33m"
BLUE       = "\e[1;34m"

ON_BLUE    = "\e[44m"
REVERSE    = "\e[7m"
UNDERLINE    = "\e[4m"


def pinfo text
  print "#{BOLD}#{YELLOW}#{text}#{BOLD_OFF}#{CLEAR}\n"
end
def perror text
  $stderr.print "#{BOLD}#{RED}#{text}#{BOLD_OFF}#{CLEAR}\n"
end
def pdone text
  $stdout.print "#{BOLD}#{GREEN}#{text}#{BOLD_OFF}#{CLEAR}\n"
end


if __FILE__ == $0
  begin
    # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
        $verbose = v
      end
      opts.on("-d", "--[no-]debug", "Run with debug info") do |v|
        options[:debug] = v
        $debug = v
      end
    end.parse!

    if $verbose
      p options 
      p ARGV
    end

    filename=ARGV[0];
    run(filename)
  ensure
  end
end

