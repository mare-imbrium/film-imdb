#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: readbyte.rb
#  Description: reads the given file from the given offset, to the first blank line.
#   The third argument is the regex to read until.
#   In the case of the plot file it is "^-------".
#       Author:  jkepler
#         Date: 2015-12-01 or so
#  Last update: 2015-12-11 12:39
#      License: MIT License
# ----------------------------------------------------------------------------- #


filename=ARGV[0];
offset=ARGV[1].to_i;
till=ARGV[2] || "^$"
reg = Regexp.new till
File.open(filename) do |f|
    f.seek(offset, IO::SEEK_SET)
      #p f.read(10)
    while (line = f.gets)
      line = line.chomp
      break if line =~ reg
      puts line
    end
end

