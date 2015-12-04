#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: normalize.rb
#  Description: take imdb file and make into one row per entry, now being used to aka-titles
#       Author:  r kumar
#         Date: 2015-10-28 - 19:16
#  Last update: 2015-12-04 00:04
#      License: MIT License
# ----------------------------------------------------------------------------- #
# used aka-titles.pru as input and generated aka-titles.tsv
def progressbar i
  $stderr.write "\r#{i}"
end

def printme (filename, ofilename)

  dir = ""
  delim = "	" # TAB
  startchar=" " # space
  counter = 0
  
  ofile = File.open(ofilename, 'w') 
  File.open(filename).each { |line|
    next if line =~ /^$/
    # if line starts with TAB then its a movie or tv show
    # in aka-titles it is spaces followed by (aka
    if line[0] == startchar
      l = line.chomp.strip
      # ignore if TV show
      next if l[0] == '"'
      #next if l =~ /\(TV\)/ or l =~ /\(VG\)/ or l =~ /\(V\)/
      next if !l.index("(TV)").nil? 
      next if  !l.index("(VG)").nil? 
      next if !l.index("(V)").nil?
      next if !l.index('(aka "').nil?
      # remove extra stuff from line
      linearray = l.split(delim)
      alttitle = linearray.first[/ *aka (.*)\)$/,1]
      ofile.print "#{dir}#{delim}#{alttitle}#{delim}#{linearray[1]}\n"
    else
    # this line contains director followed by movie
      # here it contains the main movie title, usually a foreign name
      # TODO i would like to ignore all directors starting with a ? 
      #  but what if they have a movie.
      arr = line.chomp.split(delim)
      dir = arr.first
      l = arr.last
      next if !l.index("(TV)").nil? 
      next if  !l.index("(VG)").nil? 
      next if !l.index("(V)").nil?
      next if !l.index('(aka "').nil?
      counter += 1
      progressbar counter
      #print "%s | %s\n", % [dir, l]
      # here we don't have a movie name after the first name, so nothing to print
      #print "#{dir} | #{l}\n"
    end
  }
  puts
  puts "Written #{counter} lines to #{ofilename}"
  ofile.close
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
      end
    end.parse!

    #p options
    #p ARGV

    filename=ARGV[0];
    ofile = File.basename(filename ,File.extname(filename))
    ofile += ".tsv"
    # or just get the extn and replace with another extn.
    printme filename, ofile
  ensure
  end
end

