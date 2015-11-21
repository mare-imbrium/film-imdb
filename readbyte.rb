#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: ,,F
#  Description: 
#       Author:  r kumar
#         Date: ,,D
#  Last update: 2015-11-20 20:39
#      License: MIT License
# ----------------------------------------------------------------------------- #


filename=ARGV[0];
offset=ARGV[1].to_i;
#till=ARGV[2]
File.open(filename) do |f|
    f.seek(offset, IO::SEEK_SET)
      #p f.read(10)
    while (line = f.gets)
      line = line.chomp
      break if line =~ /^$/
      puts line
    end
end

