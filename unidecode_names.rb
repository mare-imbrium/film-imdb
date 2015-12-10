#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: unidecode_names.rb
#  Description: Loops through names.tsv checks if name has diacritcs and unidecodes
#       Author:  r kumar
#         Date: 2015-12-06 - 18:59
#  Last update: 2015-12-08 13:20
#      License: MIT License
# ----------------------------------------------------------------------------- #
#
require 'unidecoder'
require 'open3'

def progress_counter 
  $my_progress_counter ||= 1
  $stderr.write "\r#{$my_progress_counter}"
  $my_progress_counter += 1
end
def main(filename)

  # to remove possible ./ which i might put in a file to use completion
  filename = File.basename(filename);
  foutname = "ascii_#{filename}"
  $stdout.write "Writing to #{foutname}\n"
  fout = File.open(foutname, 'w') ;
  File.open(filename).each { |line|
    line = line.chomp
    next if line =~ /^$/
    cols = line.split("\t")
    ascname = cols[0].to_ascii
    if ascname != cols[0]
      # we have a diacritical name
      ascnewname = cols[1].to_ascii
      fout.print "#{ascname}\t#{ascnewname}\t#{cols[0]}\n"
      progress_counter()
    end
  }
  fout.close
  puts
  puts "sorting file "
  Open3.pipeline("sort #{foutname}" , "sponge #{foutname}")
  cmd = "wc -l #{foutname} #{filename}" 
  system(cmd)
  puts "Done"
end





if __FILE__ == $0
  $opt_verbose = false
  begin
    # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
        $opt_verbose = v
      end
    end.parse!

    p options if $opt_verbose
    p ARGV if $opt_verbose

    filename=ARGV[0] || "names.tsv";
    main(filename)
  ensure
  end
end

