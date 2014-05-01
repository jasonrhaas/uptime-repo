 #!/bin/bash

# This bash script goes out to each server and writes the data in /proc/upti    me
# to /usr/share/tuptime/$SERVER/uptime for each server

SERVER15='server15'
SERVER16='server16'
SERVER29='server29'
SERVERS=($SERVER15 $SERVER16 $SERVER29)
UPTIME_DIR='/usr/share/tuptime/'

# Check if the uptime directory is there.  If not, make it.
if [ ! -d $UPTIME_DIR ]; then
        mkdir $UPTIME_DIR
fi

echo ${SERVERS[@]}

# Check if the specific server directory is there.  If not, make it.
for server_dir in ${SERVERS[@]}
do
        if [ ! -d "$UPTIME_DIR$server_dir" ]; then
                mkdir "$UPTIME_DIR$server_dir"
        fi
done

# ssh into each server and write out the uptime data to a local file stored
# on the host server.
for server in ${SERVERS[@]}
do
        ssh root@$server cat /proc/uptime > "$UPTIME_DIR$server/uptime" &&
        cat /proc/stat > "$UPTIME_DIR$server/stat"
done
