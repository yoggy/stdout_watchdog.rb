#!/usr/bin/ruby

STDOUT.sync = true

loop do
  5.times do
    puts Time.new.to_i
    sleep 0.5
  end
  sleep 7
end
