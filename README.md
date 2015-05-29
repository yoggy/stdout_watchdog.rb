stdout_watchdog.rb
====
simple watchdog program. (Linux only)

example
----
    $ ./stdout_watchdog.rb ping 192.168.1.102
    start process...cmd=ping 192.168.1.102
    PING 192.168.1.102 (192.168.1.102) 56(84) bytes of data.
    64 bytes from 192.168.1.102: icmp_req=10 ttl=64 time=411 ms
    64 bytes from 192.168.1.102: icmp_req=12 ttl=64 time=251 ms
    64 bytes from 192.168.1.102: icmp_req=14 ttl=64 time=93.1 ms
    .
    .
    (disconnect)
    .
    .
    execution expired
    restarting process...t=3
    restarting process...t=2
    restarting process...t=1
    start process...cmd=ping 192.168.1.102
    PING 192.168.1.102 (192.168.1.102) 56(84) bytes of data.
    64 bytes from 192.168.1.102: icmp_req=2 ttl=64 time=39.9 ms
    64 bytes from 192.168.1.102: icmp_req=3 ttl=64 time=140 ms
    .
    .
    ^C
    ^C
