#!/usr/bin/ruby
#
# stdout_watchdog.rb - simple watchdog program
#
# github:
#     https://github.com/yoggy/stdout_watchdog.rb
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
unless File.exists?("./.stdout_watchdog.so")
  open(".stdout_watchdog.c", "w") do |f|
    f.puts <<-EOS
#include <dlfcn.h>
#include <stdio.h>

#if defined(RTLD_NEXT)
#define REAL_LIBC RTLD_NEXT
#else
#define REAL_LIBC ((void *) -1L)
#endif

static void (*orig_setbuf)(FILE*, char*) = NULL;
static int (*orig_setvbuf)(FILE*, char*, int, size_t) = NULL;

static void __attribute__ ((constructor))
_constructor()
{
  puts("_constructor()");
  orig_setbuf = (void(*)(FILE*, char*))dlsym(REAL_LIBC, "setbuf");
  orig_setvbuf = (int(*)(FILE*, char*, int, size_t))dlsym(REAL_LIBC, "setvbuf");

  orig_setvbuf(stdout, NULL, _IONBF, 0);
  orig_setvbuf(stderr, NULL, _IONBF, 0);
}

void
setbuf(FILE *fp, char *buf)
{
  puts("setbuf()");
  if (fp == stdout || fp == stderr) {
    return orig_setbuf(fp, NULL);
  }
  return orig_setbuf(fp, buf);
}

int
setvbuf(FILE *fp, char *buf, int mode, size_t size)
{
  puts("setvbuf()");
  if (fp == stdout || fp == stderr) {
    return orig_setvbuf(fp, NULL, _IONBF, 0);
  }
  return orig_setvbuf(fp, buf, mode, size);
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
# watch dog main loop...
#
cmd = ARGV.map{|s| s=~/\s/?"'#{s}'":s}.join(" ")
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
  
  3.downto(1) do |t|
    puts "restarting...t=#{t}"
    sleep 1
  end
end

