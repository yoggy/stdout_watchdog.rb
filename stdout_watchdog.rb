#!/usr/bin/ruby
#
# stdout_watchdog.rb - simple watchdog program
#
# github:
#     https://github.com/yoggy/
#
# license:
#     Copyright (c) 2015 yoggy <yoggy0@gmail.com>
#     Released under the MIT license
#     http://opensource.org/licenses/mit-license.php
#
require 'open3'
require 'timeout'

$stdout.sync = true
$stderr.sync = true

#
# prepare "./stdout_watch_dog.so"
#
unless File.exists?("./stdout_watchdog.so")
  open(".stdout_watchdog.c", "w") do |f|
    f.puts <<-EOS
#include <stdio.h>
void __attribute__ ((constructor))
_constructor()
{
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stderr, NULL, _IONBF, 0);
}
EOS
  end
  system("gcc -Wall -fPIC -shared -o .stdout_watchdog.so .stdout_watchdog.c")
end

#
# print usage
#
def usage
  puts "usage : #{$0} cmd [arg1] [arg2] ..."
  exit 1
end
usage if ARGV.size == 0


#
# check File.exists?
#
unless File.exists?(ARGV[0])
	puts "#{$0}: command not found: #{ARGV[0]}"
	exit 1
end

#
# watch dog main loop...
#
cmd = ARGV.join(" ")
loop do
  puts "start process...cmd=#{cmd}"
  Open3.popen3({"LD_PRELOAD"=>"./.stdout_watchdog.so"}, cmd) do |i, o, e, w|
    begin
      loop do
      	timeout(5) do
      	  $stdout.puts o.readline
      	end
      end
    rescue Exception => e
      puts e
      begin
        Process.kill('KILL', w.pid)
      rescue Exception => e
      end
    end
  end
  
  puts "restarting process...t=3"
  sleep 1
  
  puts "restarting process...t=2"
  sleep 1
  
  puts "restarting process...t=1"
  sleep 1
end
