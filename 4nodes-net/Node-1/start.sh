#!/bin/bash
echo "Removing old node.log file..."
rm -f /root/data/node.log

echo "Starting node with relay host.docker.internal:4444"
/root/node/goal node start -p "host.docker.internal:4444"

echo "Starting kmd node"
/root/node/goal kmd start -d /root/data


/root/node/carpenter -file /root/data/node.log
