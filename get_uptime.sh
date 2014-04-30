 #!/bin/bash
  2
  3 # This bash script goes out to each server and writes the data in /proc/upti    me
  4 # to /usr/share/tuptime/$SERVER/uptime for each server
  5
  6 SERVER15='server15'
  7 SERVER16='server16'
  8 SERVER29='server29'
  9 SERVERS=($SERVER15 $SERVER16 $SERVER29)
 10 UPTIME_DIR='/usr/share/tuptime/'
 11
 12 # Check if the uptime directory is there.  If not, make it.
 13 if [ ! -d $UPTIME_DIR ]; then
 14         mkdir $UPTIME_DIR
 15 fi
 16
 17 echo ${SERVERS[@]}
 18
 19 # Check if the specific server directory is there.  If not, make it.
 20 for server_dir in ${SERVERS[@]}
 21 do
 22         if [ ! -d "$UPTIME_DIR$server_dir" ]; then
 23                 mkdir "$UPTIME_DIR$server_dir"
 24         fi
 25 done
 26
 27 # ssh into each server and write out the uptime data to a local file stored
 28 # on the host server.
 29 for server in ${SERVERS[@]}
 30 do
 31         ssh root@$server cat /proc/uptime > "$UPTIME_DIR$server/uptime" &&
 32         cat /proc/stat > "$UPTIME_DIR$server/stat"
 33 done
